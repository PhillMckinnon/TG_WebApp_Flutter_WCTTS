from sanic import Sanic
from sanic.response import json
from sanic_ext import Extend
from sanic.response import raw
import os
import tempfile
import whisper
from pydub import AudioSegment
from py_synth_file import synthesize_audio
from py_trans_file import transcribe_audio
from py_detectlang_file import detect_language
from verify_user import requires_telegram_user
import redis_limits
from dotenv import load_dotenv
load_dotenv()
app = Sanic("TelegramVoiceApp")
Extend(app)
origin1 = os.getenv('NGROK_ORIGIN')
app.config.CORS_ORIGINS = [
    origin1,  #frontend
    "https://web.telegram.org"
]
app.config.CORS_ALLOW_HEADERS = [
    "Content-Type",
    "Authorization",
    "X-Telegram-InitData",
    "x-requested-with",
    "ngrok-skip-browser-warning",
    "x-csrftoken",
    "user-agent",
    "accept"
]
app.config.CORS_EXPOSE_HEADERS = ["Authorization", "Content-Type"]
app.config.CORS_METHODS = ["GET", "POST", "OPTIONS"]
app.config.CORS_SUPPORTS_CREDENTIALS = True
app.config.CORS_AUTOMATIC_OPTIONS = True
app.config.CORS_ALWAYS_SEND = True
app.config.CORS_VARY_HEADER = True

MAX_SIZE_MB = int(os.getenv('MAX_SIZE', 20))
from pydantic import BaseModel, ValidationError
from datetime import datetime
class UserActiveData(BaseModel):
    user_id: str
    username: str
    timestamp: str


@app.get("/api/usage/<user_id>")
@requires_telegram_user
async def get_usage(request, user_id):
    key = f"user_limit:{user_id}"
    count = await redis_limits.redis.get(key)
    count = int(count) if count else 0
    limit = int(os.getenv("MAX_DAILY_LIMIT", 3))
    return json({"usage": count, "limit": limit})
@app.post("/api/mark_active")
@requires_telegram_user
async def mark_active(request):
    try:
        payload = request.json 
        print("Parsed JSON:", payload)

        data = UserActiveData(**payload)
        active_time = datetime.fromisoformat(data.timestamp)

        print(f"User {data.user_id} ({data.username}) marked active at {active_time}")

        return json({"message": "User marked active"})

    except ValidationError as ve:
        print("[VALIDATION ERROR]", ve)
        return json({"error": ve.errors()}, status=400)

    except Exception as e:
        print("[UNHANDLED EXCEPTION]", str(e))
        return json({"error": str(e)}, status=400)


@app.post("/api/detect")
@requires_telegram_user
async def detect(request):
    user_id = request.ctx.user_id
    allowed = await redis_limits.check_rate_limit(user_id)
    if not allowed:
        return json({"error": "Daily limit reached"}, status=429)
    if "file" not in request.files:
        return json({"error": "A file is required."}, status=400)
    file_obj = request.files["file"][0]
    file_bytes = file_obj.body
    filename = file_obj.name
    if len(file_bytes) > MAX_SIZE_MB * 1024 * 1024:
        return json({"error": "File too large (max 20MB)"}, status=400)
    try:
        model = whisper.load_model("small", device="cpu")
        result = detect_language(file_bytes, filename, model)
        return result
    except Exception as e:
        return json({"error": f"Audio conversion failed: {str(e)}"}, status=500)

@app.post("/api/transcribe")
@requires_telegram_user
async def handle_transcribe(request):
    user_id = request.ctx.user_id
    allowed = await redis_limits.check_rate_limit(user_id)
    if not allowed:
        return json({"error": "Daily limit reached"}, status=429)
    if "file" not in request.files:
        return json({"error": "A file is required."}, status=400)
    file_obj = request.files["file"][0]
    file_bytes = file_obj.body
    filename = file_obj.name
    if len(file_bytes) > MAX_SIZE_MB * 1024 * 1024:
        return json({"error": "File too large (max 20MB)"}, status=400)
    try:
        model = whisper.load_model("small", device="cpu")
        result = transcribe_audio(file_bytes, filename, model)
        await redis_limits.increment_rate_limit(user_id)
        return result
    except Exception as e:
        return json({"error": f"Audio conversion failed: {str(e)}"}, status=500)

@app.post("/api/synthesize")
@requires_telegram_user
async def handle_synthesize(request):
    user_id = request.ctx.user_id
    allowed = await redis_limits.check_rate_limit(user_id)
    if not allowed:
        return json({"error": "Daily limit reached"}, status=429)

    form = request.form  
    if "file" not in request.files or "text" not in form:
        return json({"error": "A file and text input are required."}, status=400)

    file_obj = request.files["file"][0]
    file_bytes = file_obj.body
    filename = file_obj.name

    text_input = form.get("text")
    language = form.get("language")

    if len(file_bytes) > MAX_SIZE_MB * 1024 * 1024:
        return json({"error": "File exceeds the limit (20MB)"}, status=400)

    try:
        with tempfile.TemporaryDirectory() as tmpdir:
            input_path = os.path.join(tmpdir, filename)
            wav_path = os.path.join(tmpdir, "converted.wav")
            output_path = os.path.join(tmpdir, "output.wav")

            with open(input_path, "wb") as f:
                f.write(file_bytes)

            audio = AudioSegment.from_file(input_path)
            duration_sec = len(audio) / 1000
            if duration_sec > 360:
                return json({"error": "Audio exceeds the 6 minute limit."}, status=400)

            audio.export(wav_path, format="wav")
            if not os.path.exists(wav_path):
                return json({"error": "WAV conversion failed."}, status=400)

            synthesize_audio(text_input, wav_path, output_path, language)

            with open(output_path, "rb") as f:
                output_bytes = f.read()
        await redis_limits.increment_rate_limit(user_id)
        return raw(
            output_bytes,
            headers={
                "Content-Disposition": "attachment; filename=synthesized_output.wav",
                "Content-Type": "audio/wav",
            }
        )
    except Exception as e:
        return json({"error": f"Audio conversion failed: {str(e)}"}, status=500)


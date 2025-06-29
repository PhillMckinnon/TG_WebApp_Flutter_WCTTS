from functools import wraps
from sanic.response import json as sanic_json
from sanic import Request
from telegram_web_auth import verify_telegram_webapp
from urllib.parse import parse_qs
import json

def requires_telegram_user(handler):
    @wraps(handler)
    async def wrapper(request: Request, *args, **kwargs):
        print("\n==== [@requires_telegram_user] ====")
        print("[REQUEST] Method:", request.method)
        print("[HEADERS]:", dict(request.headers))

        try:
            body_bytes = request.body
            print("[RAW BODY]:", body_bytes.decode("utf-8"))
        except Exception as e:
            print("[ERROR] Could not decode body:", str(e))

        init_data = None

        # 1. Check query param
        if request.args.get("initData"):
            init_data = request.args.get("initData")
            print("[initData] Found in query parameters.")
        # 2. Check POST form (skipped if content-type is JSON)
        elif request.method == "POST" and request.headers.get("content-type", "").startswith("application/x-www-form-urlencoded"):
            try:
                form = await request.form()
                init_data = form.get("initData")
                print("[initData] Found in POST form.")
            except Exception as e:
                print("[ERROR] Failed to parse form data:", str(e))
        # 3. Check custom header
        elif "x-telegram-initdata" in request.headers:
            init_data = request.headers.get("x-telegram-initdata")
            print("[initData] Found in x-telegram-initdata header.")

        if not init_data:
            print("[ERROR] initData not found in query, form, or headers.")
            return sanic_json({"error": "Missing initData"}, status=400)

        print("[initData] Raw:", init_data)

        # Validate initData signature
        is_valid = verify_telegram_webapp(init_data)
        print("[verify_telegram_webapp] Result:", is_valid)

        if not is_valid:
            print("[ERROR] Telegram WebApp signature check failed.")
            return sanic_json({"error": "Unauthorized"}, status=403)

        try:
            parsed = dict(parse_qs(init_data))
            user_json = parsed.get("user", [None])[0]
            print("[Parsed initData keys]:", list(parsed.keys()))
            print("[Parsed user JSON]:", user_json)

            if user_json:
                request.ctx.telegram_user = json.loads(user_json)
                request.ctx.user_id = request.ctx.telegram_user.get("id")
                print("[User ID]:", request.ctx.user_id)
                print("[Username]:", request.ctx.telegram_user.get("username"))
            else:
                print("[WARNING] No user data in initData.")
                request.ctx.telegram_user = None
        except Exception as e:
            print("[ERROR] Failed to parse user data:", str(e))
            request.ctx.telegram_user = None

        print("==== [@requires_telegram_user END] ====\n")
        return await handler(request, *args, **kwargs)

    return wrapper



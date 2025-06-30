import time
import json
import hmac
import hashlib
import urllib.parse
import os
from telegram_web_auth import verify_telegram_webapp
from dotenv import load_dotenv

load_dotenv()
BOT_TOKEN = os.getenv('TELEGRAM_BOT_TOKEN', "token")
#replace with an actual token for accurate tests

def create_test_init_data(bot_token, auth_date=None):
    if auth_date is None:
        auth_date = int(time.time())
    data = {
        "auth_date": str(auth_date),
        "query_id": "123456",
        "user": json.dumps({"id": 12345, "first_name": "Test"})
    }
    data_check_string = "\n".join(f"{k}={v}" for k, v in sorted(data.items()))
    secret_key = hmac.new(b"WebAppData", bot_token.encode(), hashlib.sha256).digest()
    hash_val = hmac.new(secret_key, data_check_string.encode(), hashlib.sha256).hexdigest()
    data["hash"] = hash_val
    return urllib.parse.urlencode(data)


#def test_verify_valid_data():
#    init_data = create_test_init_data(BOT_TOKEN)
#    assert verify_telegram_webapp(init_data) is True


def test_verify_invalid_hash():
    init_data = create_test_init_data(BOT_TOKEN)
    # Corrupt the hash by replacing last char
    corrupted_data = init_data[:-1] + ('0' if init_data[-1] != '0' else '1')
    assert verify_telegram_webapp(corrupted_data) is False


def test_verify_missing_hash():
    init_data = create_test_init_data(BOT_TOKEN)
    # Remove the hash param entirely
    params = dict(urllib.parse.parse_qsl(init_data))
    params.pop("hash", None)
    no_hash_data = urllib.parse.urlencode(params)
    assert verify_telegram_webapp(no_hash_data) is False


def test_verify_expired_auth_date():
    # Set auth_date older than 1 day (e.g., 2 days ago)
    expired_date = int(time.time()) - (2 * 86400)
    init_data = create_test_init_data(BOT_TOKEN, auth_date=expired_date)
    assert verify_telegram_webapp(init_data) is False


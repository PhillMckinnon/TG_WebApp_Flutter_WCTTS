import hmac
import hashlib
import urllib.parse
import os
from dotenv import load_dotenv
load_dotenv()
BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")

if not BOT_TOKEN:
    raise ValueError("Telegram bot token not found")

BOT_TOKEN = BOT_TOKEN.strip()

def verify_telegram_webapp(init_data: str) -> bool:
    """
    Verifies the init_data received from Telegram WebApp.
    :return: True if verification passes, False otherwise
    """
    # Parse the query string into a dictionary
    data = dict(urllib.parse.parse_qsl(init_data))

    # Extract the hash value from the data
    received_hash = data.pop("hash", None)
    if not received_hash:
        return False  # no hash means no verification possible

    # Sort the data fields alphabetically and build the data-check-string
    data_check_list = [f"{k}={data[k]}" for k in sorted(data.keys())]
    data_check_string = "\n".join(data_check_list)

    # Generate the secret key
    secret_key = hmac.new(
        key=b"WebAppData",
        msg=BOT_TOKEN.encode(),
        digestmod=hashlib.sha256
    ).digest()

    # Compute the HMAC-SHA256 hex digest of the data-check-string with the secret key
    computed_hash = hmac.new(
        key=secret_key,
        msg=data_check_string.encode(),
        digestmod=hashlib.sha256
    ).hexdigest()

    # Compare the computed hash with the received hash (constant-time compare)
    if not hmac.compare_digest(computed_hash, received_hash):
        return False

    # Optionally, verify that auth_date is recent (e.g., not older than 1 day)
    auth_date = int(data.get("auth_date", 0))
    import time
    now = int(time.time())
    if auth_date == 0 or (now - auth_date) > 86400:
        return False

    # Passed all checks
    return True

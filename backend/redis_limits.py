from redis.asyncio import Redis
import os
from dotenv import load_dotenv

load_dotenv()

MAX_DAILY_LIMIT = int(os.getenv("MAX_DAILY_LIMIT", 3))
redis = Redis(host="redis", port=6379, decode_responses=True)

async def check_rate_limit(user_id):
    key = f"user_limit:{user_id}"
    count = await redis.get(key)
    if count is None:
        return True
    return int(count) < int(MAX_DAILY_LIMIT)

async def increment_rate_limit(user_id):
    key = f"user_limit:{user_id}"
    count = await redis.get(key)
    if count is None:
        await redis.set(key, 1, ex=86400)
    else:
        await redis.incr(key)
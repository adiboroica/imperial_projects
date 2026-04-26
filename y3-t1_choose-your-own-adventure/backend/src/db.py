import motor.motor_asyncio
from urllib.parse import urlparse
from src.config import get_db_url


class Database:
    def __init__(self):
        self.client = None
        self.db = None

    async def connect(self):
        url = get_db_url()
        self.client = motor.motor_asyncio.AsyncIOMotorClient(url)
        parsed = urlparse(url)
        db_name = parsed.path.lstrip("/") or "cyoa"
        self.db = self.client[db_name]

    async def close(self):
        if self.client:
            self.client.close()


_database = Database()


async def connect_db():
    await _database.connect()


async def close_db():
    await _database.close()


def get_db():
    if _database.db is None:
        raise RuntimeError("Database not connected. Call connect_db() first.")
    return _database.db

import os


def get_db_url():
    return os.getenv("DB_URL", "mongodb://localhost:27017/cyoa")


def get_app_url() -> str:
    return os.getenv("APP_URL", "http://localhost:3000")

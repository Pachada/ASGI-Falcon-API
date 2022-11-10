import configparser
from contextlib import asynccontextmanager
from sqlalchemy.ext.asyncio import create_async_engine, exc, AsyncSession as DB_Session
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime
from core.Utils import Utils


Config = configparser.ConfigParser()
Config.read(Utils.get_config_ini_file_path())

host = Config.get("DATABASE", "host")
port = Config.get("DATABASE", "port")
database = Config.get("DATABASE", "database")
user = Config.get("DATABASE", "user")
password = Config.get("DATABASE", "password")

engine = create_async_engine(
    f"mysql+asyncmy://{user}:{password}@{host}:{port}/{database}",
    pool_size=20,
    max_overflow=10,
    pool_recycle=3600,
    pool_timeout=10,
    isolation_level="READ UNCOMMITTED",
    pool_pre_ping=True
)


#db_session = sessionmaker(engine, expire_on_commit=False, class_=AsyncSession)
def async_session_generator():
    return sessionmaker(engine, expire_on_commit=False, class_=DB_Session)

@asynccontextmanager
async def get_db_session() -> DB_Session:
    try:
        async_session = async_session_generator()
        async with async_session() as session:
            yield session
    finally:
        await session.close()
        
Base = declarative_base()

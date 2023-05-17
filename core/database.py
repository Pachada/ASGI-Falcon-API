import configparser
from contextlib import asynccontextmanager
from sqlalchemy.ext.asyncio import create_async_engine, exc, AsyncSession
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
    isolation_level="READ COMMITTED"
    #pool_pre_ping=True
)


#db_session = sessionmaker(engine, expire_on_commit=False, class_=AsyncSession)
def async_session_generator():
    return sessionmaker(engine, expire_on_commit=False, class_=AsyncSession)

@asynccontextmanager
async def get_db_session() -> AsyncSession:
    try:
        async_session = async_session_generator()
        async with async_session() as session:
            yield session
    finally:
        await session.close()
        
Base = declarative_base()

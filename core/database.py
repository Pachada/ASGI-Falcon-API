import configparser
from sqlalchemy import create_engine, exc, event, select
from sqlalchemy.orm import scoped_session, sessionmaker
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

engine = create_engine(
    f"mysql+mysqlconnector://{user}:{password}@{host}:{port}/{database}",
    pool_size=20,
    max_overflow=10,
    pool_recycle=3600,
    pool_timeout=10,
    isolation_level="READ UNCOMMITTED",
    pool_pre_ping=True
)


db_session = scoped_session(
    sessionmaker(autocommit=False, autoflush=False, bind=engine)
)

Base = declarative_base()
Base.query = db_session.query_property()




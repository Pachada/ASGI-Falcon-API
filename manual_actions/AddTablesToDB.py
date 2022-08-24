from core.database import Base, engine
from models.streaks.StreaksJackpot import StreaksJackpot


table_objects = [StreaksJackpot.__table__]

Base.metadata.create_all(engine, tables=table_objects)


from core.Async_Model import *


class Person(Base, AsyncModel):
    __tablename__ = "person"
    

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    first_name = Column(String(50), default=None)
    last_name = Column(String(50), default=None)
    birthday = Column(DateTime, default=None)
    created = Column(DateTime, default=Utils.time())
    updated = Column(DateTime, default=Utils.time(), onupdate=Utils.time())
    enable = Column(Boolean, default=True)

    def __repr__(self) -> str:
        return f"{self.first_name} {self.last_name}"
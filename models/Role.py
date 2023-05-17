from core.Async_Model import *


class Role(Base, AsyncModel):
    # Roles
    ADMIN = 1
    USER = 2

    __tablename__ = "role"
    

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    name = Column(String(30), nullable=False)
    created = Column(DateTime, default=func.now())
    updated = Column(DateTime, default=func.now(), onupdate=func.now())
    enable = Column(Boolean, default=1, nullable=False)


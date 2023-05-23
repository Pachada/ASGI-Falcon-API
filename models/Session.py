from core.AsyncModel import *
from models.User import User
from models.Device import Device


class Session(Base, AsyncModel):
    __tablename__ = "session"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    user_id = Column(BigInteger, ForeignKey(User.id), nullable=False)
    device_id = Column(BigInteger, ForeignKey(Device.id), nullable=False)
    token = Column(String(120), nullable=False)
    created = Column(DateTime, default=func.now())
    updated = Column(DateTime, default=func.now(), onupdate=func.now())
    enable = Column(Boolean, default=True)

    device = relationship(Device)
    user = relationship(User)

    blacklist = {}
    
    def __repr__(self) -> str:
        return f"{self.user_id}, {self.device_id}"
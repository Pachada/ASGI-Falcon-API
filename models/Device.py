from core.AsyncModel import *
from models.User import User
from models.AppVersion import AppVersion


class Device(Base, AsyncModel):
    __tablename__ = "device"
    

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    uuid = Column(String(300), nullable=False)
    user_id = Column(Integer, ForeignKey(User.id), nullable=False)
    token = Column(String(100), default=None)
    app_version_id = Column(BigInteger, ForeignKey(AppVersion.id), default=1)
    created = Column(DateTime, default=func.now())
    updated = Column(DateTime, default=func.now(), onupdate=func.now())
    enable = Column(Boolean, default=True)

    user = relationship(User)
    app_version = relationship(AppVersion)

    blacklist = {"user"}

from core.AsyncModel import *
from models.PushNotificationTemplate import PushNotificationTemplate
from models.User import User
from models.Device import Device


class PushNotificationSent(Base, AsyncModel):
    __tablename__ = "push_notification_sent"
    

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    user_id = Column(BigInteger, ForeignKey(User.id))
    device_id = Column(BigInteger, ForeignKey(Device.id), default=None)
    template_id = Column(BigInteger, ForeignKey(PushNotificationTemplate.id))
    message = Column(String(200), nullable=False)
    readed = Column(mysql.TINYINT(1), default=0)
    created = Column(DateTime, default=func.now())
    updated = Column(DateTime, default=func.now(), onupdate=func.now())

    user = relationship(User)
    device = relationship(Device)


from core.Async_Model import *


class PushNotificationCatalogue(Base, AsyncModel):
    __tablename__ = "push_notification_catalogue"
    

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    action = Column(String(45), nullable=False)

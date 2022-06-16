from core.Model import *


class PushNotificationCatalogue(Base, Model):
    __tablename__ = "push_notification_catalogue"
    

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    action = Column(String(45), nullable=False)

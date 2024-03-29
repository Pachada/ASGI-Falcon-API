from core.AsyncModel import *
from models.PushNotificationCatalogue import PushNotificationCatalogue


class PushNotificationTemplate(Base, AsyncModel):
    # Templates                                  #Data

    __tablename__ = "push_notification_template"
    

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    name = Column(String(100), nullable=False)
    description = Column(String(500), nullable=False)
    title = Column(String(200), nullable=False)
    message = Column(String(200), nullable=False)
    private = Column(mysql.TINYINT(1), nullable=False)
    catalogue_id = Column(
        BigInteger, ForeignKey(PushNotificationCatalogue.id), nullable=False
    )
    created = Column(DateTime, default=func.now())
    updated = Column(DateTime, default=func.now(), onupdate=func.now())
    enable = Column(Boolean, default=True)

    catalogue = relationship(PushNotificationCatalogue)

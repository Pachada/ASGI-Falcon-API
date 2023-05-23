from core.AsyncModel import *
from models.SmsTemplate import SmsTemplate
from models.Status import Status
from models.User import User


class SmsPool(Base, AsyncModel):
    __tablename__ = "sms_pool"
    

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    user_id = Column(BigInteger, ForeignKey(User.id), nullable=False)
    template_id = Column(BigInteger, ForeignKey(SmsTemplate.id), nullable=False)
    status_id = Column(BigInteger, ForeignKey(Status.id), default=Status.PENDING)
    message = Column(String(160), nullable=False)
    send_time = Column(DateTime, default=func.now())
    send_attemps = Column(mysql.TINYINT(1), default=0)
    created = Column(DateTime, default=func.now())
    updated = Column(DateTime, default=func.now(), onupdate=func.now())

    template = relationship(SmsTemplate)
    status = relationship(Status)
    user = relationship(User)


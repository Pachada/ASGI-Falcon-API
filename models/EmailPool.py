from core.AsyncModel import *
from models.EmailTemplate import EmailTemplate
from models.Status import Status
from models.User import User


class EmailPool(Base, AsyncModel):
    __tablename__ = "email_pool"
    

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    user_id = Column(BigInteger, ForeignKey(User.id), nullable=False)
    template_id = Column(BigInteger, ForeignKey(EmailTemplate.id), nullable=False)
    status_id = Column(BigInteger, ForeignKey(Status.id), default=Status.PENDING)
    subject = Column(String(100), nullable=False)
    content = Column(Text, nullable=False)
    send_time = Column(DateTime, default=func.now())
    send_attemps = Column(mysql.TINYINT(1), default=0)
    created = Column(DateTime, default=func.now())
    updated = Column(DateTime, default=func.now(), onupdate=func.now())

    template = relationship(EmailTemplate)
    status = relationship(Status)
    user = relationship(User)
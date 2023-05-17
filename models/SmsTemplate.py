from core.Async_Model import *


class SmsTemplate(Base, AsyncModel):
    # Templates                  #Data
    OTP = 1  # {{otp}}

    __tablename__ = "sms_template"
    

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    name = Column(String(45), nullable=False)
    description = Column(String(500), nullable=False)
    message = Column(String(160), nullable=False)
    created = Column(DateTime, default=func.now())
    updated = Column(DateTime, default=func.now(), onupdate=func.now())
    enable = Column(Boolean, default=True)

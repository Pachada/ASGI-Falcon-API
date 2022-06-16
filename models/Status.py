from core.Model import *


class Status(Base, Model):
    # STATUS FOR PUSH NOTIFICATIONS AND EMAILS
    PENDING = 1
    PROCESSING = 2
    ERROR = 3
    SEND = 4

    # STATUS FOR THE USER VERIFICATION
    MISSING = 5
    IN_VERIFICATION = 6
    ACEPTED = 7
    REJECTED = 8
    VERIFIED = 9

    __tablename__ = "status"
    

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    description = Column(String(100), nullable=False)

from core.Async_Model import *
from models.User import User
from models.File import File
from models.Status import Status


class UserVerification(Base, AsyncModel):
    __tablename__ = "user_verification"

    user_id = Column(BigInteger, ForeignKey(User.id), primary_key=True, nullable=False)
    curp = Column(String(45), default=None)
    status_id_curp = Column(BigInteger, ForeignKey(Status.id), default=Status.MISSING)
    file_id_ine = Column(BigInteger, ForeignKey(File.id), default=None)
    status_id_ine = Column(BigInteger, ForeignKey(Status.id), default=Status.MISSING)
    comments = Column(String(450), default=None)
    updated = Column(DateTime, default=Utils.time(), onupdate=Utils.time())

    # OTP
    otp = Column(String(6), default=None)
    otp_time = Column(DateTime, default=None)
    email_otp = Column(String(6), default=None)
    email_otp_time = Column(DateTime, default=None)
    sms_otp = Column(String(6), default=None)
    sms_otp_time = Column(DateTime, default=None)

    user = relationship(User)
    status_curp = relationship(Status, foreign_keys=status_id_curp)
    file_ine = relationship(File, foreign_keys=file_id_ine)
    status_ine = relationship(Status, foreign_keys=status_id_ine)

    @staticmethod
    async def get_verification_of_user(db_session, user: User):

        user_verification = UserVerification.get(UserVerification.user_id == user.id)

        if not user_verification:
            user_verification = UserVerification(user_id=user.id)
            if not user_verification.save():
                return None

        return user_verification

from core.Controller import Controller, Utils, Request, Response, datetime
from models.UserVerification import UserVerification, User
from core.classes.SmsClient import SmsClient, SmsTemplate
from models.Session import Session, get_db_session


class ConfirmPhoneController(Controller):
    def __init__(self):
        self.actions = {
            "request": self.__request,
            "validate-code": self.__validate_code,
        }

    async def __request(self, req: Request, resp: Response):
        session: Session = req.context.session
        user: User = session.user

        if user.phone_confirmed:
            self.response(resp, 409, error="This user phone is already verified")
            return

        async with req.context.db_session as db_session:
            user_verification: UserVerification = await UserVerification.get_verification_of_user(db_session, user)
            if not user_verification: 
                self.response(resp, 500, error = "Problem with user verification")
                return

            user_verification.sms_otp = Utils.generate_otp(5)
            user_verification.sms_otp_time = datetime.utcnow()
            if not user_verification.save(db_session):
                self.response(resp, 500, error=self.PROBLEM_SAVING_TO_DB)
                return

            await SmsClient.send_sms_to_pool(SmsTemplate.OTP, user, {"otp": user_verification.sms_otp}, send_now=True)

            self.response()

    async def __validate_code(self, req: Request, resp: Response, token: str = None):
        data: dict = self.get_req_data(req, resp)
        if not data:
            return

        phone_code = data.get("otp")
        if not phone_code:
            self.response(resp, 400, error="otp field is required")
            return

        async with req.context.db_session as db_session:
            user_verification: UserVerification = UserVerification.get(db_session, UserVerification.email_otp == str(phone_code))
            if not user_verification:
                self.response(resp, 401, message="Incorrect code")
                return

            if not Utils.validate_expiration_time(user_verification.sms_otp_time, "otp"):
                self.response(resp, 401, message="code expired")
                return

            user: User  = user_verification.user
            user.phone_confirmed = 1
            user_verification.sms_otp = None
            user_verification.sms_otp_time = None
            if not user.save(db_session):
                self.response(resp, 500, error=self.PROBLEM_SAVING_TO_DB)
                return
            user_verification.save(db_session)

        self.response(resp, 200, message="Phone confirmed successfully")

    async def on_post(self, req: Request, resp: Response, action: str):
        await self.actions[action](req, resp)

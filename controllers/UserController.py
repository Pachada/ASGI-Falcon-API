from core.Controller import Controller, Utils, Request, Response
from models.Person import Person
from models.User import User, get_db_session
from core.classes.Authenticator import Authenticator, Session


class UserController(Controller):
    async def on_get(self, req: Request, resp: Response, id: int = None):
        await super().generic_on_get(req, resp, User, id)

    async def on_post(self, req: Request, resp: Response, id=None):
        if id:
            self.response(resp, 405)
            return

        data: dict = await self.get_req_data(req, resp)
        if not data:
            return

        if data.get("username") and data.get("password"):
            async with get_db_session() as session:
                req.context.db_session = session
                return await self.create_user(req, resp, data)

    async def on_put(self, req: Request, resp: Response, id: int = None):
        super().generic_on_put(req, resp, User, id)

    async def on_delete(self, req: Request, resp: Response, id: int = None):
        user: User = super().generic_on_delete(
            req, resp, User, id, return_row=True
        )
        # Delete the person and the sessions of the user
        user.person.soft_delete()
        sessions = Session.get_all(Session.user_id == user.id)
        for session in sessions:
            session.soft_delete()

    # ------------------------------- Utils -------------------------------

    async def create_user(self, req: Request, resp: Response, data: dict):
        async with req.context.db_session as db_session:
            exists, message = await User.check_if_user_exists(db_session, data.get("username"), data.get("email"))
            if exists:
                self.response(resp, 409, error=message)
                return

            user = await self.create_user_helper(req, resp, data)
            if not user:
                return

            session = await Authenticator.login(db_session, user.username, str(data.get("password")), str(data.get("device_uuid", "unknown")))
            data = {"session": Utils.serialize_model(session, recursive=True, recursiveLimit=3, blacklist=["device"])}
            self.response(resp, 201, data, message="Session started")
            resp.append_header("content_location", f"/users/{user.id}")

    async def create_user_helper(self, req: Request, resp: Response, data: dict):
        if not data.get("password"):
            self.response(resp, 400, "Password field requierd")
            return

        person = Person(
            first_name=data.get("name"),
            last_name=data.get("last_name"),
            birthday=data.get("birthday"),
        )
        if not await person.save(req.context.db_session):
            self.response(resp, 500, error=self.PROBLEM_SAVING_TO_DB)
            return

        salt = Utils.generate_salt()
        print(data.get("password"))
        password_encrypted = Utils.get_hashed_string(str(data.get("password")) + salt)
        user = User(
            username=data.get("username"),
            password=password_encrypted,
            salt=salt,
            email=data.get("email"),
            phone=data.get("phone"),
            person_id=person.id,
        )
        if not await user.save(req.context.db_session):
            self.response(resp, 500, error=self.PROBLEM_SAVING_TO_DB)
            return

        return user

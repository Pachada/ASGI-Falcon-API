from core.Controller import Controller, Request, Response
from core.Utils import Utils, date
from models.Person import Person
from models.User import User, AsyncSession, Role, get_db_session
from core.classes.middleware.Authenticator import Authenticator, Session


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

        if not data.get("username") or not data.get("password"):
            self.response(resp, 400, error="username and password are required")
            return

        return await self.create_user(req, resp, data)

    async def on_put(self, req: Request, resp: Response, id: int = None):
        # If the user.role of the session is admin it can modify every user
        # but if is not an admin it can only modify its own user
        user: User = req.context.session.user
        if user.role_id != Role.ADMIN and user.id != id:
            self.response(resp, 401, error="Users can only modify their own users")
            return
        
        await super().generic_on_put(req, resp, User, id)

    async def on_delete(self, req: Request, resp: Response, id: int = None):
        # If the user.role of the session is admin it can delete every user
        # but if is not an admin it can only modify its own user
        user: User = req.context.session.user
        if user.role_id != Role.ADMIN and user.id != id:
            self.response(resp, 401, error="Users can only delete their own users")
            return
        
        deleted_user: User = await super().generic_on_delete(req, resp, User, id, return_row=True)
        if not deleted_user:
            return
        # Delete the person and the sessions of the user
        async with get_db_session() as db_session:
            await deleted_user.person.soft_delete(db_session)
            sessions = await Session.get_all(db_session, Session.user_id == deleted_user.id, get_relationtships=False)
            for session in sessions:
                await session.soft_delete(db_session)

    # ------------------------------- Utils -------------------------------

    async def create_user(self, req: Request, resp: Response, data: dict):
        async with req.context.db_session as db_session:
            exists, message = await User.check_if_user_exists(db_session, data.get("username"), data.get("email"))
            if exists:
                self.response(resp, 409, error=message)
                return

            user = await self.create_user_helper(db_session, req, resp, data)
            if not user:
                return

            session = await Authenticator.login(db_session, user.username, str(data.get("password")), str(data.get("device_uuid", "unknown")))
            data = {"session": Utils.serialize_model(session, recursive=True, recursiveLimit=3, blacklist=["device"])}
            self.response(resp, 201, data, message="Session started")
            resp.append_header("content_location", f"/users/{user.id}")

    async def create_user_helper(self, db_session: AsyncSession, req: Request, resp: Response, data: dict):
        person = Person(
            first_name=data.get("name", "No name"),
            last_name=data.get("last_name", "No Last name"),
            birthday=data.get("birthday", date.today())
        )
        if not await person.save(db_session):
            self.response(resp, 500, error=self.PROBLEM_SAVING_TO_DB)
            return

        salt = Utils.generate_salt()
        password_encrypted = Utils.get_hashed_string(str(data.get("password")) + salt)
        user = User(
            username=data.get("username"),
            password=password_encrypted,
            salt=salt,
            email=data.get("email"),
            phone=data.get("phone"),
            person_id=person.id,
        )
        if not await user.save(db_session):
            self.response(resp, 500, error=self.PROBLEM_SAVING_TO_DB)
            return

        return user

from core.Controller import Controller, Utils, Request, Response
from core.classes.Authenticator import Authenticator
from models.Session import Session, get_db_session, DB_Session
from models.Role import Role


class SessionController(Controller):
    def __init__(self):
        self.actions = {
            "login": self.__login,
            "logout": self.__logout,
        }

    async def on_get(self, req: Request, resp: Response):
        session: Session = req.context.session
        role: Role = session.user.role
        device = session.device
        person = session.user.person

        session_data = Utils.serialize_model(session, recursive=True, recursiveLimit=2)

        session_data["role"] = Utils.serialize_model(role)
        session_data["device"] = Utils.serialize_model(device)
        session_data["person"] = Utils.serialize_model(person)
        data = {"session": session_data}
        self.response(resp, 200, data)

    async def __login(self, req: Request, resp: Response):
        data = await self.get_req_data(req, resp)
        if not data:
            return

        username = str(data.get("username", data.get("email")))
        password = str(data.get("password"))
        uuid = str(data.get("device_uuid", "unknown"))
        if not username or not password:
            self.response(resp, 400, error="Username and password are required")
            return

        async with get_db_session() as db_session:
            session = await Authenticator.login(db_session, username, password, uuid)
            if not session:
                self.response(resp, 401, error="Invalid credentials")
                return

            req.context.session = session
            data = {"session": Utils.serialize_model(session, recursive=True, recursiveLimit=3)}
            self.response(resp, 200, data, message="Session started")

    async def __logout(self, req: Request, resp: Response):
        async with get_db_session() as db_session:
            session = req.context.session
            await Authenticator.logout(db_session, session)
            self.response(resp, 200, message="Session ended")

    async def on_post(self, req: Request, resp: Response, action: str):
        await self.actions[action](req, resp)

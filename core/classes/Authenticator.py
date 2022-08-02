from falcon.asgi import Response, Request
from models.Session import Session
from models.User import User
from models.Device import Device
from core.Utils import Utils, logger
from sqlalchemy import and_
import json


class Authenticator(object):
    def __init__(self):
        self.exceptions = []
        self.privileges_tree = self.__load_privileges_tree()

    def __load_privileges_tree(self):
        with open("core/roles/roles.json", "r") as roles_file:
            roles_data: dict = json.load(roles_file)
            privilegesTree = []
            for role in roles_data:
                role_privileges = {
                    "role": role["role"],
                    "privileges": self.__get_privileges(role["role"], roles_data),
                }
                privilegesTree.append(role_privileges)
            return privilegesTree

    def __get_privileges(self, role_name: str, roles_data: dict):
        # sourcery skip: for-append-to-extend, merge-duplicate-blocks, remove-redundant-if, simplify-generator, split-or-ifs
        groups = []
        privileges = []
        for role in roles_data:
            if role["role"] == role_name:
                for group in role["groups"]:
                    groups.append(group)
                for privilege in role["privileges"]:
                    privileges.append(privilege)
                break

        if not privileges and not groups:
            return

        privileges_from_groups = []
        if groups:
            with open("core/roles/groups.json", "r") as groups_file:
                groups_data = json.load(groups_file)
                for group in groups_data:
                    if group["group"] in groups:
                        for privilege in group["privileges"]:
                            privileges_from_groups.append(privilege)

        permits = []
        if privileges or privileges_from_groups:
            with open("core/roles/privileges.json", "r") as privileges_file:
                privileges_data = json.load(privileges_file)
                for privilege in privileges_data:
                    if (
                        privilege["name"] in privileges
                        or privilege["name"] in privileges_from_groups
                    ):
                        privilege_dict = {
                            "method": privilege["method"],
                            "resource": privilege["resource"],
                        }
                        permits.append(privilege_dict)

        if not permits:
            return
        return permits

    def __has_privileges(self, role_name, method, resource):
        # sourcery skip: use-next
        privileges = []
        for role in self.privileges_tree:
            if role["role"] == role_name:
                privileges = role["privileges"]
                break
        if not privileges:
            return False
        resources = [privilege["resource"] for privilege in privileges if privilege["method"] == method]

        return resource in resources if resources else False

    def __role_privileges(self, role_name):
        for role in self.privileges_tree:
            if role["role"] == role_name:
                return role["privileges"]

    def add_exception_route(self, route):
        self.exceptions.append(route)

    async def process_request(self, req: Request, resp: Response):
        # Process the request before routing it.
        pass

    async def process_resource(self, req: Request, resp: Response, resource, params):
        # If the route or the route with out the id is in exceptions, session is None
        if req.path in self.exceptions or "/".join(req.path.split('/')[:-1]) in self.exceptions:
            req.context.session = None
        else:
            session = Session.get(Session.token == req.auth)
            if not session:
                logger.warning("No session")
                resource.response(resp, 401, error="Unauthorized")
                resp.complete = True
                return

            if not Utils.validate_expiration_time(session.updated, "session"):
                logger.warning("Session expired")
                self.logout(session)
                resource.response(resp, 401, message="Session expired")
                resp.complete = True
                return

            role_name = session.user.role.name
            method = req.method
            resource_name = type(resource).__name__
            if not self.__has_privileges(role_name, method, resource_name):
                logger.warning("No privileges")
                resource.response(resp, 401, message="Unauthorized")
                resp.complete = True
                return

            req.context.session = session

    async def process_response(self, req: Request, resp: Response, resource, req_succeeded):
        # Post-processing of the response (after routing).
        pass
    
    async def process_request_ws(self, req, ws):
        """Process a WebSocket handshake request before routing it.

        Note:
            Because Falcon routes each request based on req.path, a
            request can be effectively re-routed by setting that
            attribute to a new value from within process_request().

        Args:
            req: Request object that will eventually be
                passed into an on_websocket() responder method.
            ws: The WebSocket object that will be passed into
                on_websocket() after routing.
        """
        pass

    async def process_resource_ws(self, req, ws, resource, params):
        """Process a WebSocket handshake request after routing.

        Note:
            This method is only called when the request matches
            a route to a resource.

        Args:
            req: Request object that will be passed to the
                routed responder.
            ws: WebSocket object that will be passed to the
                routed responder.
            resource: Resource object to which the request was
                routed.
            params: A dict-like object representing any additional
                params derived from the route's URI template fields,
                that will be passed to the resource's responder
                method as keyword arguments.
        """

    @staticmethod
    def login(username, password, device_uuid="unknown"):
        if user := User.get(User.username == username):
            password = Utils.get_hashed_string(password + user.salt)
            if password == user.password:
                if session := Authenticator.start_user_session(user, device_uuid):
                    return session
        return None

    @staticmethod
    def login_by_otp(user, device_uuid="unknown"):
        return Authenticator.start_user_session(user, device_uuid)

    @staticmethod
    def start_user_session(user: User, device_uuid):
        device = Device.get(and_(Device.user_id == user.id, Device.uuid == device_uuid))

        if device is None:
            device = Device(
                uuid=device_uuid,
                user_id=user.id,
            )
            device.save()

        session = Session.get(
            and_(Session.user_id == user.id, Session.device_id == device.id)
        )

        if session is None:
            session = Session(user_id=user.id, device_id=device.id)

        session.token = Utils.generate_token()
        session.save()
        return session

    @staticmethod
    def logout(session: Session):
        return session.soft_delete()

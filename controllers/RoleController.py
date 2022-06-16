from core.Controller import Controller, Request, Response
from models.Role import Role


class RoleController(Controller):
    async def on_get(self, req: Request, resp: Response, id: int = None):
        super().generic_on_get(req, resp, Role, id)

    async def on_post(self, req: Request, resp: Response, id: int = None):
        super().generic_on_post(req, resp, Role, "roles", id)

    async def on_put(self, req: Request, resp: Response, id: int = None):
        super().generic_on_put(req, resp, Role, id)

    async def on_delete(self, req: Request, resp: Response, id: int = None):
        super().generic_on_delete(req, resp, Role, id)

from core.Controller import Controller, Request, Response
from models.Status import Status, and_


class StatusController(Controller):
    async def on_get(self, req: Request, resp: Response, id: int = None):
        super().generic_on_get(req, resp, Status, id)

    async def on_post(self, req: Request, resp: Response, id: int = None):
        super().generic_on_post(req, resp, Status, id)

    async def on_put(self, req: Request, resp: Response, id: int = None):
        super().generic_on_put(req, resp, Status, id)

    async def on_delete(self, req: Request, resp: Response, id: int = None):
        super().generic_on_delete(req, resp, Status, id, soft_delete=False)

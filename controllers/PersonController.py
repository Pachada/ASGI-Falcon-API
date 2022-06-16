from core.Controller import Controller, Request, Response
from models.Person import Person


class PersonController(Controller):
    async def on_get(self, req: Request, resp: Response, id: int = None):
        super().generic_on_get(req, resp, Person, id)

    async def on_post(self, req: Request, resp: Response, id: int = None):
        super().generic_on_post(req, resp, Person, id)

    async def on_put(self, req: Request, resp: Response, id: int = None):
        super().generic_on_put(req, resp, Person, id)

    async def on_delete(self, req: Request, resp: Response, id: int = None):
        super().generic_on_delete(req, resp, Person, id)

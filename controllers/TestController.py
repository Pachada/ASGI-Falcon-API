from core.Controller import Controller, Utils, Request, Response, json, datetime


class TestController(Controller):
    async def on_get(self, req: Request, resp: Response):
        pass

    async def on_post(self, req: Request, resp: Response):
        pass

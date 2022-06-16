from core.Controller import Controller, datetime
from core.Utils import Utils
from models.NewsType import NewsType


class NewsTypeController(Controller):
    async def on_get(self, req, resp):
        types = NewsType.get_all()
        data = Utils.serialize_model(types)
        self.response(resp, 200, data)

    async def on_post(self, req, resp):
        pass

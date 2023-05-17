from core.database import get_db_session, AsyncSession
from falcon.asgi import Response, Request

class SQLAlchemySessionManager:
    async def process_request(self, req: Request, resp: Response):
        req.context.db_session: AsyncSession = get_db_session()

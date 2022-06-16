from core.database import db_session as DB


class SQLAlchemySessionManager:
    async def process_response(self, req, resp, resource, req_succeeded):
        if DB:
            if not req_succeeded:
                DB.rollback()
            DB.commit()
            DB.close()

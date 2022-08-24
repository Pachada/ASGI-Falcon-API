


class SQLAlchemySessionManager:
    async def process_response(self, req, resp, resource, req_succeeded):
        if session:
            if not req_succeeded:
                session.rollback()
            session.commit()
            session.close()

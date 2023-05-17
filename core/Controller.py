import contextlib
import asyncio
from falcon.asgi import Response, Request, WebSocket
from falcon import code_to_http_status, WebSocketDisconnected, create_task
from datetime import datetime, timedelta, time
import json
from core.Utils import Utils, logger
from core.Async_Model import *


class Controller:
    """
    The Controller class inherits new controllers classes and
    provide them with methods to return different responses depending its necessity.

    """

    # Error mesages
    MISSING_OR_EXCESSIVE_PARAMS = "Bad Request - Your request is missing or excessive parameters. Please verify and resubmit."
    PROBLEM_SAVING_TO_DB = "Internal Server Error - problem saving to database."
    INVALID_JSON = "Bad Request - Invalid JSON"
    ID_NOT_FOUND = "Not Found - Invalid ID"

    def response(self, resp, http_code=200, data=None, message=None, error=None, error_code=None):
        resp.status = code_to_http_status(http_code)
        if isinstance(data, list) and not data:
            data = []
        elif not data:
            data = {}
        if message:
            data["message"] = message
        if error:
            data["error"] = error
        if error_code:
            data["error_code"] = error_code
        resp.text = json.dumps(data, ensure_ascii=False)

    async def set_values(self, db_session: AsyncSession, row: AsyncModel, data: dict):
        try:
            for col in row.__table__.columns.keys():
                if col in data:
                    if col == "password":
                        password = Utils.get_hashed_string(data[col])
                        setattr(row, col, password)
                        continue

                    setattr(row, col, data[col])

            return await row.save(db_session)

        except Exception as exc:
            logger.error("[ERROR-SETTING_VALUES]")
            logger.error(exc)
            return False

    async def get_req_data(self, req: Request, resp: Response):
        try:
            data: dict = json.loads(await req.stream.read())
        except Exception as exc:
            logger.error("[ERROR-GETTING-REQUEST-DATA]")
            logger.error(exc)
            self.response(resp, 400, error=str(exc))
            return

        return data

    async def get_model_object(self, db_session: AsyncSession, resp: Response, model: AsyncModel, id: int = None):
        if not id:
            self.response(resp, 405)
            return

        row = await model.get(db_session, id)
        if not row:
            self.response(resp, 404, error=self.ID_NOT_FOUND)
            return

        return row

    async def generic_on_get(
        self,
        req: Request,
        resp: Response,
        model: AsyncModel,
        id: int = None,
        filters=None,
        join=None,
        order_by=None,
        recursive=False,
        recursiveLimit=2,
    ):
        async with req.context.db_session as db_session:
            if id:
                row = await self.get_model_object(db_session, resp, model, id)
                if not row:
                    return
            else:
                row = await model.get_all(db_session, filters, join=join, orderBy=order_by)

            self.response(resp, 200, Utils.serialize_model(row, recursive=recursive, recursiveLimit=recursiveLimit),)

    async def generic_on_post(
        self,
        req: Request,
        resp: Response,
        model: AsyncModel,
        id: int = None,
        data=None,
        extra_data: dict = None
    ):
        if id:
            self.response(resp, 405)
            return
        if not data:
            data = self.get_req_data(req, resp)
        if not data:
            return
        if extra_data:
            data.update(extra_data)

        new_record = model()

        async with req.context.db_session as db_session:
            if not await self.set_values(db_session, new_record, data):
                self.response(resp, 500, error=self.PROBLEM_SAVING_TO_DB)
                return

        self.response(resp, 201, Utils.serialize_model(new_record))

    async def generic_on_put(
        self,
        req: Request,
        resp: Response,
        model: AsyncModel,
        id: int = None,
        data=None,
        extra_data: dict = None
    ):
        if not id:
            self.response(resp, 405)
            return
        
        async with req.context.db_session as db_session:
            row = await self.get_model_object(db_session, resp, model, id)
            if not row:
                return
            if not data:
                data = await self.get_req_data(req, resp)
            if not data:
                return
            if extra_data:
                data.update(extra_data)

            if not await self.set_values(db_session, row, data):
                self.response(resp, 500, self.PROBLEM_SAVING_TO_DB)
                return

        self.response(resp, 200, Utils.serialize_model(row))

    async def generic_on_delete(
        self,
        req: Request,
        resp: Response,
        model: AsyncModel,
        id: int = None,
        soft_delete: bool = True,
        delete_file: bool = False,
        return_row: bool = False
    ):
        if not id:
            self.response(resp, 405)
            return

        async with req.context.db_session as db_session:
            row: AsyncModel = await self.get_model_object(db_session, resp, model, id)
            if not row:
                return

            data = Utils.serialize_model(row)

            if delete_file:
                row.delete_model_files(req, resp)
                if not row.exists_in_database():  # Checamos que el row aún exista
                    self.response(resp, 200, data)
                    if return_row:
                        return row
                    return

            deleted = await row.soft_delete(db_session) if soft_delete else await row.delete(db_session)
            if not deleted:
                self.response(resp, 500, error=self.PROBLEM_SAVING_TO_DB)
                return

        self.response(resp, 200, data)

        if return_row:
            return row

 # -------------------------------- Webscokets --------------------------------
    async def accept_wb(self, ws: WebSocket, clients: set):
        try:
            await ws.accept()
            clients.add(ws)
        except WebSocketDisconnected:
            await self.cleanup(ws)
            return

    async def cleanup(self, ws: WebSocket, clients: set):
        with contextlib.suppress(KeyError):
            clients.remove(ws)

    async def send_message_to_all(self, ws: WebSocket, clients: set, name: str, message: str):
        try:
            for client in clients:
                if client is ws:
                    continue
                if not client.ready:
                    await self.cleanup(client)
                await client.send_text(f"{name}: {message}")
                # await client.send_media(
                #        {'username': name, 'message': message}
                #    )
        except WebSocketDisconnected:
            await self.cleanup(ws)
            return

    async def ws_response(self, ws: WebSocket, data=None, code=1000, message=None, error=None, error_code=None):

        if isinstance(data, list) and not data:
            data = []
        elif not data:
            data = {}
        if message:
            data["message"] = message
        if error:
            data["error"] = error
        if error_code:
            data["error_code"] = error_code
        await ws.send_media(data)
        await ws.close(code)

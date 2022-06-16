from falcon.asgi import Response, Request
from falcon import code_to_http_status
from datetime import datetime, timedelta, time
import json
from core.Utils import Utils, logger
from core.Model import Model


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

    def response(
        self, resp, http_code=200, data=None, message=None, error=None, error_code=None
    ):
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

    def set_values(self, row: Model, data: dict):
        try:
            for col in row.__table__.columns.keys():
                if col in data:
                    if col == "password":
                        password = Utils.get_hashed_string(data[col])
                        setattr(row, col, password)
                        continue

                    setattr(row, col, data[col])

            return row.save()

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

    def get_model_object(self, resp: Response, model: Model, id: int = None):
        if not id:
            self.response(resp, 405)
            return

        row = model.get(id)
        if not row:
            self.response(resp, 404, error=self.ID_NOT_FOUND)
            return

        return row

    def generic_on_get(
        self,
        req: Request,
        resp: Response,
        model: Model,
        id: int = None,
        filters=None,
        join=None,
        order_by=None,
        recursive=False,
        recursiveLimit=2,
    ):
        if id:
            row = self.get_model_object(resp, model, id)
            if not row:
                return
        else:
            row = model.get_all(filters, join=join, orderBy=order_by)

        self.response(
            resp,
            200,
            Utils.serialize_model(
                row, recursive=recursive, recursiveLimit=recursiveLimit
            ),
        )

    def generic_on_post(
        self,
        req: Request,
        resp: Response,
        model: Model,
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

        if not self.set_values(new_record, data):
            self.response(resp, 500, error=self.PROBLEM_SAVING_TO_DB)
            return

        self.response(resp, 201, Utils.serialize_model(new_record))
        #resp.append_header("content_location", f"/{content_location}/{new_record.id}")

    def generic_on_put(
        self,
        req: Request,
        resp: Response,
        model: Model,
        id: int = None,
        data=None,
        extra_data: dict = None
    ):
        if not id:
            self.response(resp, 405)
            return
        row = self.get_model_object(resp, model, id)
        if not row:
            return
        if not data:
            data = self.get_req_data(req, resp)
        if not data:
            return
        if extra_data:
            data.update(extra_data)

        if not self.set_values(row, data):
            self.response(resp, 500, self.PROBLEM_SAVING_TO_DB)
            return

        self.response(resp, 200, Utils.serialize_model(row))

    def generic_on_delete(
        self,
        req: Request,
        resp: Response,
        model: Model,
        id: int = None,
        soft_delete: bool = True,
        delete_file: bool = False,
        return_row: bool = False
    ):
        if not id:
            self.response(resp, 405)
            return

        row: Model = self.get_model_object(resp, model, id)
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

        deleted = row.soft_delete() if soft_delete else row.delete()
        if not deleted:
            self.response(resp, 500, error=self.PROBLEM_SAVING_TO_DB)
            return

        self.response(resp, 200, data)

        if return_row:
            return row

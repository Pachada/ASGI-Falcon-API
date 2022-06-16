from core.Controller import Controller, Utils, Request, Response
from models.Device import Device, AppVersion


class DeviceController(Controller):
    async def on_put_version(self, req: Request, resp: Response):
        """

        Checks if the version of the app the devices is running is equal or greater then the current app version

        if the version of the device is lower than the current version, returns HTTP_409 code
        else a HTTP_200 code

        """
        data: dict = self.get_req_data(req, resp)
        if not data:
            return

        app_version = AppVersion.get_actual_version_class()
        if float(data.get("device_version")) < app_version.version:
            self.response(resp, 409, error="Updated the app in the store")
            return

        device: Device = req.context.session.device
        if device.app_version_id != app_version.id:
            device.app_version_id = app_version.id
            device.save()

        self.response(resp, 200)

    async def on_put_token(self, req: Request, resp: Response):
        """
        Adds the notification token to the device of the current session
        """
        data: dict = self.get_req_data(req, resp)
        if not data:
            return

        if not data.get("token"):
            self.response(resp, 400, error="token needed")
            return

        device: Device = req.context.session.device
        device.token = data.get("token")
        if not device.save():
            self.response(resp, 500, error=self.PROBLEM_SAVING_TO_DB)
            return

        self.response(resp, 200, Utils.serialize_model(device))

    async def on_get(self, req: Request, resp: Response, id: int = None):
        super().generic_on_get(req, resp, Device, id)

    async def on_put(self, req: Request, resp: Response, id: int = None):
        super().generic_on_put(req, resp, Device, id)

    async def on_delete(self, req: Request, resp: Response, id: int = None):
        super().generic_on_delete(req, resp, Device, id)

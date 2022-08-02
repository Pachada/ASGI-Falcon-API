import copy
from collections import defaultdict
from core.Controller import (
    Controller, 
    Utils, 
    Request, 
    Response, 
    json, 
    datetime, 
    WebSocket,
    WebSocketDisconnected,
    create_task,
    asyncio
)
from models.AppVersion import AppVersion

clients = set()
class TestController(Controller):
    app_clients = defaultdict(list)

    async def on_websocket(self, req: Request, ws: WebSocket, id: int = None):
        if not id:
            ws.close()
        
        app_version: AppVersion = AppVersion.get(id)
        if not app_version:
            ws.close()

        await self.accept_wb(ws, clients)
        self.app_clients[app_version.id].append(ws)

        while True:
            try:
                await asyncio.sleep(10)
                old = copy.deepcopy(app_version)
                app_version.refresh_object()
                if app_version != old:
                    for client in self.app_clients[app_version.id]:
                        if not client.ready:
                            self.app_clients[app_version.id].remove(client)
                        await client.send_media(Utils.serialize_model(app_version))
            except WebSocketDisconnected:
                await self.cleanup(ws, clients)
                return

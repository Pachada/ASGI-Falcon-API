import contextlib
from core.Controller import (
    Controller, 
    Utils, 
    Request, 
    Response, 
    json, 
    datetime, 
    WebSocket,
    WebSocketDisconnected,
    create_task
)


clients = set()
class TestController(Controller):
    async def on_get(self, req: Request, resp: Response):
        pass

    async def on_post(self, req: Request, resp: Response):
        pass

    async def on_websocket(self, req: Request, ws: WebSocket):
        try:
            await ws.accept()
            clients.add(ws)
        except WebSocketDisconnected:
            await self.cleanup(ws)
            return
        
        # Send an instance of str as a WebSocket TEXT (0x01) payload
        await ws.send_text("Para participar en el chat necesitamos tu nombre: ")
        ws_name = await ws.receive_text()
        
        req.context.ws_name = ws_name
        
        await ws.send_text(f"Bienvenido {ws_name}, por favor solo utiliza malas palabras")
        await ws.send_text(f"Hay {len(clients)} usuario conectados actualmente")

        while True:
            try:
                message = await ws.receive_text()
                #payload_bytes = await ws.receive_data()
                #media_object = await ws.receive_media()
                await self.send_message_to_all(ws, ws_name, message)

            except WebSocketDisconnected:
                await self.cleanup(ws, req.context.ws_name)
                return
                
        """async def sink():
            while True:
                try:
                    message = await ws.receive_text()
                except WebSocketDisconnected:
                    self.cleanup(ws)
                    break

                messages.append(message)

        sink_task = create_task(sink())

        while not sink_task.done():
            while ws.ready and not messages and not sink_task.done():
                await asyncio.sleep(0)

            try:
                await ws.send_text(messages.popleft())
            except falcon.WebSocketDisconnected:
                break

        sink_task.cancel()
        try:
            await sink_task
        except asyncio.CancelledError:
            pass"""

    async def send_message_to_all(self, ws: WebSocket, name:str, message:str):
        try:
            for client in clients:
                if client is ws:
                    continue
                if not client.ready:
                    await self.cleanup(client)
                await client.send_text(f"{name}: {message}")
                #await client.send_media(
                #        {'username': name, 'message': message}
                #    )
        except WebSocketDisconnected:
                await self.cleanup(ws, name)
                return


    async def cleanup(self,ws: WebSocket, name="Anonimo"):
        message = "Se ha desconectado"
        await self.send_message_to_all(ws, name, message)
        with contextlib.suppress(KeyError):
            clients.remove(ws)

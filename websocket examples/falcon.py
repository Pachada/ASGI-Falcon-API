import falcon.asgi
import falcon.media


class SomeResource:

    # Get a paginated list of events via a regular HTTP request.
    #
    #   For small-scale, all-in-one apps, it may make sense to support
    #   both a regular HTTP interface and one based on WebSocket
    #   side-by-side in the same deployment. However, these two
    #   interaction models have very different performance characteristics,
    #   and so larger scale-out deployments may wish to specifically
    #   designate instance groups for one type of traffic vs. the
    #   other (although the actual applications may still be capable
    #   of handling both modes).
    #
    async def on_get(self, req: Request, account_id: str):
        pass

    # Push event stream to client. Note that the framework will pass
    #   parameters defined in the URI template as with HTTP method
    #   responders.
    async def on_websocket(self, req: Request, ws: WebSocket, account_id: str):

        # The HTTP request used to initiate the WebSocket handshake can be
        #   examined as needed.
        some_header_value = req.get_header('Some-Header')

        # Reject it?
        if some_condition:
            # If close() is called before accept() the code kwarg is
            #   ignored, if present, and the server returns a 403
            #   HTTP response without upgrading the connection.
            await ws.close()
            return

        # Examine subprotocols advertised by the client. Here let's just
        #   assume we only support wamp, so if the client doesn't advertise
        #   it we reject the connection.
        if 'wamp' not in ws.subprotocols:
            # If close() is not called explicitly, the framework will
            #   take care of it automatically with the default code (1000).
            return

        # If, after examining the connection info, you would like to accept
        #   it, simply call accept() as follows:
        try:
            await ws.accept(subprotocol='wamp')
        except WebSocketDisconnected:
            return

        # Simply start sending messages to the client if this is an event
        #   feed endpoint.
        while True:
            try:
                event = await my_next_event()

                # Send an instance of str as a WebSocket TEXT (0x01) payload
                await ws.send_text(event)

                # Send an instance of bytes, bytearray, or memoryview as a
                #   WebSocket BINARY (0x02) payload.
                await ws.send_data(event)

                # Or if you want it to be serialized to JSON (by default; can
                #   be customized via app.ws_options.media_handlers):
                await ws.send_media(event)  # Defaults to WebSocketPayloadType.TEXT
            except WebSocketDisconnected:
                # Do any necessary cleanup, then bail out
                return

        # ...or loop like this to implement a simple request-response protocol
        while True:
            try:
                # Use this if you expect a WebSocket TEXT (0x01) payload,
                #   decoded from UTF-8 to a Unicode string.
                payload_str = await ws.receive_text()

                # Or if you are expecting a WebSocket BINARY (0x02) payload,
                #   in which case you will end up with a byte string result:
                payload_bytes = await ws.receive_data()

                # Or if you want to get a serialized media object (defaults to
                #   JSON deserialization of text payloads, and MessagePack
                #   deserialization for BINARY payloads, but this can be
                #   customized via app.ws_options.media_handlers).
                media_object = await ws.receive_media()

            except WebSocketDisconnected:
                # Do any necessary cleanup, then bail out
                return
            except TypeError:
                # The received message payload was not of the expected
                #   type (e.g., got BINARY when TEXT was expected).
                pass
            except json.JSONDecodeError:
                # The default media deserializer uses the json standard
                #   library, so you might see this error raised as well.
                pass

            # At any time, you may decide to close the websocket. If the
            #   socket is already closed, this call does nothing (it will
            #   not raise an error.)
            if we_are_so_done_with_this_conversation():
                # https://developer.mozilla.org/en-US/docs/Web/API/CloseEvent
                await ws.close(code=1000)
                return

            try:
                # Here we are sending as a binary (0x02) payload type, which
                #   will go find the handler configured for that (defaults to
                #   MessagePack which assumes you've also installed that
                #   package, but this can be customized as mentioned above.')
                await ws.send_media(
                    {'event': 'message'},
                    payload_type=WebSocketPayloadType.BINARY,
                )

            except WebSocketDisconnected:
                # Do any necessary cleanup, then bail out. If ws.close() was
                #   not already called by the app, the framework will take
                #   care of it.

                # NOTE: If you do not handle this exception, it will be
                #   bubbled up to a default error handler that simply
                #   logs the message as a warning and then closes the
                #   server side of the connection. This handler can be
                #   overridden as with any other error handler for the app.

                return

        # ...or run a couple of different loops in parallel to support
        #  independent bidirectional message streams.

        messages = collections.deque()

        async def sink():
            while True:
                try:
                    message = await ws.receive_text()
                except falcon.WebSocketDisconnected:
                    break

                messages.append(message)

        sink_task = falcon.create_task(sink())

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
            pass


class SomeMiddleware:
    async def process_request_ws(self, req: Request, ws: WebSocket):
        # This will be called for the HTTP request that initiates the
        #   WebSocket handshake before routing.
        pass

    async def process_resource_ws(self, req: Request, ws: WebSocket, resource, params):
        # This will be called for the HTTP request that initiates the
        #   WebSocket handshake after routing (if a route matches the
        #   request).
        pass


app = falcon.asgi.App(middleware=SomeMiddleware())
app.add_route('/{account_id}/messages', SomeResource())
from falcon.asgi import App
from engine.routes import RouteLoader
from core.classes.middleware.Authenticator import Authenticator
from core.classes.middleware.CORS_Handler import CORS_Handler
from core.classes.middleware.SQLAlchemySessionManager import SQLAlchemySessionManager

authorization_middleware = Authenticator()
CORS_middleware = CORS_Handler()
sqlalchemy_session_manager = SQLAlchemySessionManager()

# Create server
def create_server():

    server = App(middleware=[CORS_middleware, authorization_middleware, sqlalchemy_session_manager])

    # Load routes
    routeLoader = RouteLoader(server, authorization_middleware)
    routeLoader.loadRoutes()
    routeLoader.loadExceptionRoutes()

    return server

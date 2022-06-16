import uvicorn
from engine.server import create_server

server = create_server()

if __name__ == '__main__':
    uvicorn.run(server)

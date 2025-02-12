from fastapi import FastAPI
from models import ServerStatusResponse, Server
import json

app = FastAPI()

class ValidationError(Exception):
    pass

@app.get("/servers")
def read_server_list() -> list[Server]:
    with open("servers.txt", "r") as f:
        servers: list[Server] = []
        for line in f.readlines():
            if line.strip():
                json_object = json.loads(line)
                try:
                    new_server = Server(**json_object)
                except ValidationError:
                    pass
                else:
                    servers.append(new_server) 
    
    return servers  


@app.post("/servers")
def add_new_server(name:str,cpu=int,ram=int):
    with open("servers.txt", "a") as f:
        try:
            new_server = Server(name=name, online=True, cpus=cpu, ram=ram)
            f.write("\n")
            f.write(new_server.model_dump_json())
        except:
            return {"message":"error trying to add server to file"}
    return  ServerStatusResponse(new_server.name,new_server.online)
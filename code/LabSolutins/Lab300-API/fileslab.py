import json
from pydantic import BaseModel

class Server(BaseModel):
    name:str
    online:bool
    CPUs:int 

with open("servers.txt","r") as file:
    # data = file.read()
    for line in file.readlines():
        json_object = json.loads(line)
        try:
            new_server = Server(**json_object)
        except:


# data = json.load(data)
# print(data)
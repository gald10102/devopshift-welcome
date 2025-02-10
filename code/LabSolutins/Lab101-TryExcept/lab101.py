class ServerError(Exception):
    pass

server_list = {"nginx": True ,"docker": False ,"aws": False}

user_input = input("give me a server name: ")
try:
    server_list[user_input]
except:
    print("Server not found")
if server_list.__contains__(user_input):
    if server_list[user_input]:
        print("Server is up")
    else:
        print("Server is down")



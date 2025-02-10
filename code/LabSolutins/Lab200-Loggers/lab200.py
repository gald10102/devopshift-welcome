import os
import sys
import logging 
import json

#user can enter LOG_LEVEL or LOG_FORMAT

class JsonFormatter(logging.Formatter):
    def format(self, record):
        log_record = {
            "level": record.levelname,
            "timestamp": self.formatTime(record, self.datefmt),
            "message": record.getMessage(),
        }
        return json.dumps(log_record)
    
# getting the arguments from the user
logging_level = os.environ.get("LOGLEVEL", "DEBUG")
logging_format = os.environ.get("FORMAT", "text")
print (logging_format)
# logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger("myapp")
logger.setLevel(logging_level)
handler = logging.StreamHandler(sys.stdout)
if logging_format == "JSON":
    handler.setFormatter(JsonFormatter()) # setting the handler to format to json
logger.addHandler(handler)
server_list = {"nginx": True ,"docker": False ,"aws": False}

while True:
    user_input = input("give me a server name: ")
    try:
        server_list[user_input]
        logger.info("server: %s",user_input)
        
    except:
        print("Server not found")
        logger.error("server not found!")
    if server_list.__contains__(user_input):
        if server_list[user_input]:
            print("Server is up")
            logger.info("server %s is up",user_input)
        else:
            print("Server is down")
            logger.info("server %s is down",user_input)



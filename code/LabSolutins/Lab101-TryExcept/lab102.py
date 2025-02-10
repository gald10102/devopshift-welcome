import sys
import logging
import os 

#log_level = sys.argv[1]
log_level = os.environ.get('LOGLEVEL', "DEBUG")
print (log_level)
logging.basicConfig(filename="myapp.log", level=log_level)
logger = logging.getLogger("gal")
logger.debug("This is a debug message")
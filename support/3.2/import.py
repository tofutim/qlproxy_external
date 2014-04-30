#!/usr/bin/env python
#
# (c) Diladele B.V. 2014, Diladele Web Safety for Squid Proxy
#  
# Uploads monitoring statistics of Diladele Web Safety to local database 
# for Web Administration Console. In Linux this script is run by cron every 
# hour with help of /etc/cron.hourly/qlproxy_report. In FreeBSD is run daily 
# using /usr/local/etc/periodic/daily/qlproxy_report script
#
import os
import sys
import time
import logging
import datetime
import string
import urlparse
import collections

#
# in order for Django to work correctly with our monitor app, we add ourselves
# to Python's search path
sys.path.append(os.path.abspath(__file__))

#
# tell Django where to read settings from
#
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "qlproxy.settings")

#
# do imports
#
from django.db.models import Count, Sum
from django.db import connections, transaction
from monitor.models import *
from config.general import Monitoring
from qlproxy.settings import QLPROXY_GLOBALS, DATABASES

#
# and go
#   
class RawEvent:
    pass
    
#
#
#
class Cache:
    
    type_to_storage = {}
    
    def get(self, model, param):
        
        # get the storage from type
        storage = self.type_to_storage.get(model, None)
        if storage is None:
            
            # create new storage
            storage = {}
            
            # and save in into map
            self.type_to_storage[model] = storage
    
        # see if the object in the cache
        object = storage.get(param, None)
        if object == None:

            # no, create or get it from db
            object, created = self.get_model(model).objects.get_or_create(value=param)
            
            # and save into storage
            storage[param] = object
            
        return object
        
    def get_model(self, name):
        map = {
            "UserIP"   : UserIP,  
            "UserName" : UserName, 
            "Message"  : Message, 
            "Policy"   : Policy, 
            "Level"    : Level,
            "Verdict"  : Verdict, 
            "Module"   : Module, 
            "Host"     : Host, 
            "Scheme"   : Scheme, 
            "Method"   : Method
        }
        model = map.get(name, None)
        if model == None:
            raise Exception("Invalid model name %s" % name)
            
        return model

#
#
#    
class Parser:
    file = ""
    
    def __init__(self, file):
        self.file = file
        
    cache = Cache()
        
    def get_entries(self):    
        events = []
        for line in [line.strip() for line in open(self.file)]:
            event = RawEvent()
            if self.parse_event(event, line):
                events.append(event)
                
        return events
        
    def parse_event(self, event, line):      
    
        line   = self.parse_timestamp(event, line)
        fields = collections.deque(string.split(line))
        
        event.iid       = fields.popleft()
        event.duration  = fields.popleft()
        event.size      = fields.popleft()
        event.message   = self.cache.get("Message", fields.popleft())
        
        if event.message == 'OPTIONS':
            return False  # we exclude OPTIONS requests from database
            
        event.user_ip   = self.cache.get("UserIP", fields.popleft())
        event.user_name = self.cache.get("UserName", fields.popleft())
        event.policy    = self.cache.get("Policy", fields.popleft())
        event.level     = self.cache.get("Level", fields.popleft())
        event.verdict   = self.cache.get("Verdict", fields.popleft())
        event.module    = self.cache.get("Module", fields.popleft())
        event.param1    = fields.popleft()
        event.param2    = fields.popleft()
        event.mtime     = fields.popleft()
        
        method_name = fields.popleft()
        if method_name == 'CONNECT':
            self.parse_connect(event, fields)
        else:
            self.parse_method(event, fields)
        
        event.method = self.cache.get("Method", method_name)
            
        return True
            
    def parse_method(self, event, fields):
        host = fields.popleft()        
        url  = urlparse.urlparse(fields.popleft())
        
        event.host   = self.cache.get("Host", host)
        event.scheme = self.cache.get("Scheme", url.scheme)
        event.path   = url.path
        event.params = url.params
            
    def parse_connect(self, event, fields):
        host = fields.popleft()
        url  = urlparse.urlparse(fields.popleft())
        
        event.host   = self.cache.get("Host", host)
        event.scheme = self.cache.get("Scheme", "connect")
        event.path   = url.path
        event.params = ""
        
    def parse_timestamp(self, event, line):
        start = string.index(line, "[")
        end   = string.index(line, "]")
        if end - start < 20:
            raise Exception("Incorrect [date_time] field found in " + line)
            
        event.now = line[start + 1:end]
        line      = line[end+1:].strip()
        return line
        
class Uploader():

    def upload(self, entry):    
        event = Event()
        event.iid       = entry.iid
        event.timestamp = entry.now
        event.message   = entry.message
        event.user_ip   = entry.user_ip
        event.user_name = entry.user_name
        event.size      = entry.size
        event.duration  = entry.duration
        event.policy    = entry.policy
        event.level     = entry.level
        event.verdict   = entry.verdict
        event.method    = entry.method
        event.module    = entry.module
        event.param1    = entry.param1
        event.param2    = entry.param2
        event.mtime     = entry.mtime
        event.scheme    = entry.scheme
        event.host      = entry.host
        event.path      = entry.path
        event.params    = entry.params
        event.save()

def upload_file(file, count, max):
    logging.info("Uploading file %d of %d, %s..." % (count + 1, max, file,))
        
    # parse file and get entries from it
    parser   = Parser(file)
    entries  = parser.get_entries()
        
    logging.debug("Found %s monitor events." % len(entries))
    
    # create uploader
    uploader = Uploader()
    
    # upload each enty being in a transaction
    for entry in entries:
        uploader.upload(entry)

    logging.debug("File %s uploaded successfully." % file)
    
def humanize_bytes(bytes, precision=1):
    abbrevs = (
        (1<<50L, 'PB'),
        (1<<40L, 'TB'),
        (1<<30L, 'GB'),
        (1<<20L, 'MB'),
        (1<<10L, 'kB'),
        (1, 'bytes')
    )
    if bytes == 1:
        return '1 byte'
    for factor, suffix in abbrevs:
        if bytes >= factor:
            break
    return '%.*f %s' % (precision, bytes / factor, suffix)
    
    
def purge():

    # ask how many days to keep in database
    days  = Monitoring.objects.all()[0].channel_db_purge_after_days        
    limit = datetime.datetime.now() - datetime.timedelta(days=days)

    logging.info("Purging events older than %d days (%s)..." % (days, limit))

    events = Event.objects.filter(timestamp__lte=limit)
    if len(events) > 0:
        events.delete()

    logging.info("Purged successfully.")
    
def upload(only_parse):

    dir = os.path.join(QLPROXY_GLOBALS['VAR'], "monitor")
    
    logging.info("Enumerating folder %s..." % dir)
    
    count = 0
    files = []
    sizes = []
    for name in os.listdir(dir):
        if name.endswith(".monitor"):
            files.append(os.path.join(dir, name))
            sizes.append(os.path.getsize(os.path.join(dir, name)))
            
    logging.info("Found %d monitor files to upload, total size %s..." % (len(files), humanize_bytes(sum(sizes))))
            
    for file in files:        
        # construct path
        path = os.path.join(dir, file)            
            
        # upload
        try:
            upload_file(path, count, len(files))
            
            # remove
            if not only_parse:
                os.remove(path)   
                logging.info("File %s removed." % (path,))

        except Exception as e:
            logging.error("Cannot upload file %s, error %s, please send it to support@diladele.com for analysis" % (path, str(e)));
        count = count + 1
            
    # and purge
    purge()
    
#
# main
#
def main():
    verbose = False
    leave   = False
    start   = time.time()

    # parse args
    for arg in sys.argv:
        if arg in ["--help", "-h"]:
            print "usage: python import.py --verbose --leave"
            print "\t--verbose - print additional information"
            print "\t--leave   - do not erase monitor files"
            return
        if arg == "--verbose" or arg == "-v":
            verbose = True
        if arg == "--leave" or arg == "-l":
            leave = True

    level = logging.INFO
    if verbose == True:
        level = logging.DEBUG
        
    logging.basicConfig(format='%(asctime)s %(message)s', level=level)
            
    # run
    logging.info("Diladele Web Safety Monitor is starting...")

    # check for a pidfile to see if another copy of the script already runs
    pid = os.path.join(QLPROXY_GLOBALS['VAR'], "run", "import.py.pid")
    try:
        import fcntl
        
        fout = open(pid, 'w')
        fcntl.flock(fout, fcntl.LOCK_EX | fcntl.LOCK_NB)
        fout.write(str(os.getpid()))
            
    except ImportError:        
        pass # the fcntl module is not present on Windows, just run then ignoring locks
            
    except IOError:
        sys.stderr.write("Cannot lock PID file %s. Script is already running, this instance will now exit.\n" % pid)
        sys.exit(1)
        
    # if we got here then we own the lock, run the import
    logging.debug("Script is run at %s" % datetime.datetime.now().strftime("%Y-%m-%d, %H:%M:%S"))
    
    # dump the type and name of the database
    logging.info("Using database engine %s" % DATABASES['monitor']['ENGINE'])
    logging.info("Using database name %s" % DATABASES['monitor']['NAME'])
    
    with transaction.commit_on_success(using="monitor"):
        upload(leave)
    
    logging.info("Monitoring information is uploaded SUCCESSFULLY in %d seconds!" % (time.time() - start))
    
if __name__ == '__main__':
    main()



    
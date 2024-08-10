from backup import ConfigBackup, ConfigFileHandler
from watchdog.observers import Observer
import time

config_file = r'bin\r4LavaEditor2.ini'
config_folder = r'bin'
cb = ConfigBackup(config_file)

cb.create_backup_dir()
cb.create_backup()

event_handler = ConfigFileHandler(cb)
observer = Observer()
observer.schedule(event_handler, config_folder, recursive=False)
observer.start()

try:
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    observer.stop()
observer.join()
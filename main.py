from backup import ConfigBackup, ConfigFileHandler
from watchdog.observers import Observer
import time
import os
from config import read_path

script_dir = read_path()

config_file = os.path.join(script_dir, r'bin\r4LavaEditor2.ini')
config_folder = os.path.join(script_dir, r'bin')

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
except Exception as e:
    print(f'Ошибка: {e}')
finally:
    observer.join()
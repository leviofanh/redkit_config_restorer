from backup import ConfigBackup, ConfigFileHandler
from watchdog.observers import Observer
import time
import os
from config import read_path

redkit_dir = read_path()

config_file_1 = os.path.join(redkit_dir, r'bin\r4LavaEditor2.ini')
config_file_2 = os.path.join(redkit_dir, r'bin\r4LavaEditor2.sessions.ini')
config_folder = os.path.join(redkit_dir, r'bin')

cb1 = ConfigBackup(config_file_1)
cb2 = ConfigBackup(config_file_2)

cb1.create_backup_dir()
cb1.create_backup()

cb2.create_backup_dir()
cb2.create_backup()

event_handler = ConfigFileHandler([cb1, cb2])

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
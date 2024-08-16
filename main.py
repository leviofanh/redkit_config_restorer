from backup import ConfigBackup
import time
import os
from config import read_path
import logging
import sys
from logging.handlers import RotatingFileHandler

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        RotatingFileHandler('backup.log', maxBytes=10*1024*1024, backupCount=3),
        logging.StreamHandler()
    ]
)

def handle_exception(exc_type, exc_value, exc_traceback):
    if issubclass(exc_type, KeyboardInterrupt):
        sys.__excepthook__(exc_type, exc_value, exc_traceback)
        return
    logging.critical('Необработанное исключение: ', exc_info=(exc_type, exc_value, exc_traceback))


logging.info('Программа запущена.')

sys.excepthook = handle_exception
redkit_dir = read_path()

config_file_1 = os.path.join(redkit_dir, r'bin\r4LavaEditor2.ini')
config_file_2 = os.path.join(redkit_dir, r'bin\r4LavaEditor2.sessions.ini')

cb1 = ConfigBackup(config_file_1)
cb2 = ConfigBackup(config_file_2)

cb1.create_backup_dir()
cb1.create_backup()
cb1.restore_from_backup()
cb1.update_backup()

cb2.create_backup_dir()
cb2.create_backup()
cb2.restore_from_backup()
cb2.update_backup()

backup_services = [cb1, cb2]

try:
    while True:
        for backup in backup_services:
            backup.check_for_changes()
        time.sleep(1)
except KeyboardInterrupt:
    logging.info('Наблюдатель остановлен пользователем.')
except Exception as e:
    logging.error(f'Ошибка: {e}', exc_info=True)
finally:
    logging.info('Программа завершена.')


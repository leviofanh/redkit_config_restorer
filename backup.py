import os
import shutil
from watchdog.events import FileSystemEventHandler
import logging


class ConfigBackup:
    def __init__(self, config_file):
        self.config_file = config_file
        self.file_name = os.path.basename(config_file)
        self.backup_dir = os.path.join(os.path.dirname(self.config_file), 'backups')
        self.main_backup_file = os.path.join(self.backup_dir, self.file_name)

    def create_backup_dir(self):
        if not os.path.exists(self.backup_dir):
            os.mkdir(self.backup_dir)
            logging.info(f'Создана директория для резервных копий: {self.backup_dir}')

    def create_backup(self):
        if not os.path.exists(self.main_backup_file):
            self.create_backup_dir()
            shutil.copy2(self.config_file, self.main_backup_file)
            logging.info(f'Создана резервная копия файла: {self.config_file}')

    def update_backup(self):
        if not os.path.getsize(self.config_file) == 0:
            shutil.copy2(self.config_file, self.main_backup_file)
            logging.info(f'Обновлена резервная копия файла: {self.config_file}')
        else:
            logging.warning(f'Файл {self.config_file} пуст, обновление резервной копии не выполнено.')

    def restore_from_backup(self):
        if os.path.getsize(self.config_file) == 0 and os.path.exists(self.main_backup_file):
            shutil.copy2(self.main_backup_file, self.config_file)
            logging.info(f'Файл {self.config_file} был восстановлен из резервной копии.')


class ConfigFileHandler(FileSystemEventHandler):
    def __init__(self, backup_services):
        self.backups = backup_services

    def on_modified(self, event):
        for backup in self.backups:
            if event.src_path == backup.config_file:
                logging.info(f'Обнаружено изменение в файле: {event.src_path}')
                backup.update_backup()
                backup.restore_from_backup()

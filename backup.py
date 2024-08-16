import os
import shutil
import logging


class ConfigBackup:
    def __init__(self, config_file):
        self.config_file = config_file
        self.file_name = os.path.basename(config_file)
        self.backup_dir = os.path.join(os.path.dirname(self.config_file), 'backups')
        self.main_backup_file = os.path.join(self.backup_dir, self.file_name)
        self.last_modified_time = self.get_last_modified_time()

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
        try:
            if os.path.getsize(self.config_file) > 0 and self.check_ini_integrity():
                shutil.copy2(self.config_file, self.main_backup_file)
                logging.info(f'Обновлена резервная копия файла: {self.config_file}')
            else:
                if os.path.getsize(self.config_file) == 0:
                    logging.warning(f'Файл {self.config_file} пуст, обновление резервной копии не выполнено.')
                else:
                    logging.warning(f'Файл {self.config_file} поврежден, обновление резервной копии не выполнено.')
        except Exception as e:
            logging.error(f'Не удалось обновить файл резервной копии: {e}')

    def restore_from_backup(self):
        try:
            if (os.path.getsize(self.config_file) == 0 or not self.check_ini_integrity()) and os.path.exists(self.main_backup_file):
                shutil.copy2(self.main_backup_file, self.config_file)
                logging.info(f'Файл {self.config_file} был восстановлен из резервной копии.')
        except Exception as e:
            logging.error(f'Не удалось восстановить файл из резервной копии: {e}')

    def check_ini_integrity(self):
        with open(self.config_file, 'r', encoding='utf-8') as file:
            content = file.read().strip()
            if not content:
                return False

            lines = content.split('\n')
            has_section = False
            has_parameter = False

            for line in lines:
                line = line.strip()
                if line.startswith('[') and line.endswith(']') and len(line) > 2:
                    has_section = True

                if '=' in line and line.split('=')[0].strip():
                    has_parameter = True

                if has_section and has_parameter:
                    return True
            return False

    def get_last_modified_time(self):
        return os.path.getmtime(self.config_file)

    def check_for_changes(self):
        current_modified_time = self.get_last_modified_time()
        if current_modified_time != self.last_modified_time:
            logging.info(f'Обнаружено изменение в файле: {self.config_file}')
            self.last_modified_time = current_modified_time
            self.restore_from_backup()
            self.update_backup()

import os
import sys


def get_config_path():
    if getattr(sys, 'frozen', False):
        return os.path.dirname(sys.executable)
    else:
        return os.path.dirname(os.path.abspath(__file__))


def read_path():
    config_path = get_config_path()
    config_file = os.path.join(config_path, 'config.ini')

    try:
        with open(config_file, 'r') as f:
            redkit_path = f.read().strip()
        return redkit_path
    except FileNotFoundError:
        print(f"Ошибка: Конфигурационный файл не найден по пути {config_file}")
        return None
    except Exception as e:
        print(f"Ошибка при чтении конфигурационного файла: {e}")
        return None

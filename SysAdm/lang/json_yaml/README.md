
### Как сдавать задания

Вы уже изучили блок «Системы управления версиями», и начиная с этого занятия все ваши работы будут приниматься ссылками на .md-файлы, размещённые в вашем публичном репозитории.

Скопируйте в свой .md-файл содержимое этого файла; исходники можно посмотреть [здесь](https://raw.githubusercontent.com/netology-code/sysadm-homeworks/devsys10/04-script-03-yaml/README.md). Заполните недостающие части документа решением задач (заменяйте `???`, ОСТАЛЬНОЕ В ШАБЛОНЕ НЕ ТРОГАЙТЕ чтобы не сломать форматирование текста, подсветку синтаксиса и прочее, иначе можно отправиться на доработку) и отправляйте на проверку. Вместо логов можно вставить скриншоты по желани.

# Домашнее задание к занятию "4.3. Языки разметки JSON и YAML"


## Обязательная задача 1
Мы выгрузили JSON, который получили через API запрос к нашему сервису:
```
{ 
    "info" : "Sample JSON output from our service\t",
    "elements" :[
        { "name" : "first",
        "type" : "server",
        "ip" : "71.75.22.33" 
        },
        { "name" : "second",
        "type" : "proxy",
        "ip" : "71.78.22.43"
        }
    ]
}
```
  Нужно найти и исправить все ошибки, которые допускает наш сервис

## Обязательная задача 2
В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: `{ "имя сервиса" : "его IP"}`. Формат записи YAML по одному сервису: `- имя сервиса: его IP`. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import socket
import os
import json
import yaml
from sys import argv


FILE = 'last_ip'
EXTS = ['json', 'yml']
SERVICES = (
    'drive.google.com',
    'mail.google.com',
    'google.com',
)


def get_service_ip(service: str) -> str:
    return socket.gethostbyname(service)


def get_service_ip_dict(services: list) -> dict:
    res = dict()
    for s in services:
        res[s] = get_service_ip(s)
    return res


def get_last_service_ip_dict(file_name: str, ext: str) -> dict:
    with open('.'.join([file_name, ext]), 'r') as f:
        if ext == 'json':
            result = json.load(f)
        elif ext == 'yml':
            result = yaml.safe_load(f)
    return result


def set_new_service_ip(file_name: str, service_dict: dict, exts: list):
    for ext in exts:
        with open('.'.join([FILE, ext]), 'w') as f:
            if ext == 'json':
                f.write(json.dumps(service_dict))
            elif ext == 'yml':
                f.write(yaml.dump(service_dict))


def print_service(service_dict: dict):
    for k, v in service_dict.items():
        print(f'{k} - {v}')


def service_check(services: list, dict_new: dict, dict_last: dict) -> bool:
    res = True
    for service in services:
        if dict_new[service] != dict_last[service]:
            res = False
            print(f'[ERROR] {service} IP mismatch: {dict_last[service]} {dict_new[service]}')
    return res


if __name__ == '__main__':

    service_dict_new = get_service_ip_dict(SERVICES)
    print_service(service_dict_new)
    print('-'*50)

    for extention in EXTS:
        if not os.path.exists('.'.join([FILE, extention])):
            set_new_service_ip(FILE, service_dict_new, [extention,])

    if len(argv) > 1 and argv[1] in ['yml', 'yaml']:
        service_dict_last = get_last_service_ip_dict(FILE, 'yml') 
    else:
        service_dict_last = get_last_service_ip_dict(FILE, 'json')

    check_result = service_check(SERVICES, service_dict_new, service_dict_last)
    if not check_result:
        set_new_service_ip(FILE, service_dict_new, EXTS)

```

### Вывод скрипта при запуске при тестировании:
```

PS D:\tmp\cc> & C:/Python/Python310/python.exe d:/tmp/cc/s.py
drive.google.com - 173.194.222.194
mail.google.com - 64.233.161.17
google.com - 142.250.150.139
--------------------------------------------------
[ERROR] drive.google.com IP mismatch: 64.233.165.194 173.194.222.194
PS D:\tmp\cc> & C:/Python/Python310/python.exe d:/tmp/cc/s.py
drive.google.com - 74.125.205.194
mail.google.com - 64.233.162.18
google.com - 173.194.73.102
--------------------------------------------------
[ERROR] drive.google.com IP mismatch: 173.194.222.194 74.125.205.194
[ERROR] mail.google.com IP mismatch: 64.233.161.17 64.233.162.18
[ERROR] google.com IP mismatch: 142.250.150.139 173.194.73.102
PS D:\tmp\cc> & C:/Python/Python310/python.exe d:/tmp/cc/s.py
drive.google.com - 74.125.205.194
mail.google.com - 64.233.162.18
google.com - 64.233.161.100
--------------------------------------------------
[ERROR] google.com IP mismatch: 173.194.73.102 64.233.161.100
PS D:\tmp\cc> & C:/Python/Python310/python.exe d:/tmp/cc/s.py yaml
drive.google.com - 64.233.162.194
mail.google.com - 64.233.165.83
google.com - 74.125.205.138
--------------------------------------------------
[ERROR] drive.google.com IP mismatch: 74.125.205.194 64.233.162.194
[ERROR] mail.google.com IP mismatch: 64.233.162.18 64.233.165.83
[ERROR] google.com IP mismatch: 64.233.161.100 74.125.205.138
PS D:\tmp\cc> & C:/Python/Python310/python.exe d:/tmp/cc/s.py yml 
drive.google.com - 64.233.162.194
mail.google.com - 64.233.165.83
google.com - 74.125.205.138
--------------------------------------------------
PS D:\tmp\cc> & C:/Python/Python310/python.exe d:/tmp/cc/s.py json
drive.google.com - 64.233.162.194
mail.google.com - 64.233.165.83
google.com - 74.125.205.138
--------------------------------------------------
```

### json-файл(ы), который(е) записал ваш скрипт:
```json
{"drive.google.com": "64.233.162.194", "mail.google.com": "64.233.165.83", "google.com": "74.125.205.138"}
```

### yml-файл(ы), который(е) записал ваш скрипт:
```yaml
drive.google.com: 64.233.162.194
google.com: 74.125.205.138
mail.google.com: 64.233.165.83

```

## Дополнительное задание (со звездочкой*) - необязательно к выполнению

Так как команды в нашей компании никак не могут прийти к единому мнению о том, какой формат разметки данных использовать: JSON или YAML, нам нужно реализовать парсер из одного формата в другой. Он должен уметь:
   * Принимать на вход имя файла
   * Проверять формат исходного файла. Если файл не json или yml - скрипт должен остановить свою работу
   * Распознавать какой формат данных в файле. Считается, что файлы *.json и *.yml могут быть перепутаны
   * Перекодировать данные из исходного формата во второй доступный (из JSON в YAML, из YAML в JSON)
   * При обнаружении ошибки в исходном файле - указать в стандартном выводе строку с ошибкой синтаксиса и её номер
   * Полученный файл должен иметь имя исходного файла, разница в наименовании обеспечивается разницей расширения файлов

### Ваш скрипт:
```python
#!/usr/bin/env python3

from sys import argv
import os
import json
import yaml


ERRORS = (
    ('00', 'ЗАГЛУШКА'),
    ('01', 'Не передан аргумент для запуска скрипта'),
    ('02', 'Файл не существует'),
    ('03', 'Не является файлом'),
    ('04', 'Содержимое не является JSON или YAML'),
    ('05', 'Проблема в JSON'),
)


def print_error(err: int, text: str, errors: tuple):
    print(f'[ERROR] [{errors[err][0]}] - {errors[err][1]}: {text}')
    # exit(err)


def is_json(file_name: str) -> bool:
    with open(file_name, 'r') as f:
        content = f.read().strip()
        if content[0] == '{' and content[-1] == '}':
            return True
    return False


def is_yaml(file_name: str) -> bool:
    with open(file_name, 'r') as f:
        if f.read().strip().split('\n')[0] == '---':
            return True
    return False


def get_new_name(name: str, ext: str) -> str:
    if name.find('.') == -1:
        return '.'.join([name, ext])
    return '.'.join([*name.split('.')[:-1], ext])


def check_json(file_name: str):
    with open(file_name, 'r') as f:
        json.load(f)


def convert_json_to_yaml(file_name: str):
    with open(file_name, 'r') as json_f:
        with open(get_new_name(file_name, 'yml'), 'w') as yaml_f:
            yaml_f.write('---\n')
            yaml_f.write(yaml.safe_dump(json.load(json_f), indent=2))


def convert_yaml_to_json(file_name: str):
    with open(file_name, 'r') as yaml_f:
        with open(get_new_name(file_name, 'json'), 'w') as json_f:
            json_f.write(json.dumps(yaml.safe_load(yaml_f), indent=2))


if __name__ == '__main__':

    if len(argv) < 2: print_error(1, '', ERRORS); exit(1)      

    file_name = argv[1]
    if not os.path.exists(file_name): print_error(2, file_name, ERRORS); exit(2)
    if not os.path.isfile(file_name): print_error(3, file_name, ERRORS); exit(3)
    
    file_type = file_name.split('.')[-1]
    
    if is_yaml(file_name):
        if file_type.lower() != 'yml' or file_type.lower() != file_type:
            old_file_name, file_name = file_name, get_new_name(file_name, 'yml')
            os.rename(old_file_name, file_name)
        convert_yaml_to_json(file_name)
    
    elif is_json(file_name):
        if file_type.lower() != 'json' or file_type.lower() != file_type:
            old_file_name, file_name = file_name, get_new_name(file_name, 'json')
            os.rename(old_file_name, file_name)
        try:
            check_json(file_name)
        except Exception as err:
            print_error(5, err, ERRORS)
            exit(5)
        convert_json_to_yaml(file_name)

    else:
        print_error(4, file_name, ERRORS)
        exit(4)
```

### Пример работы скрипта:
```
PS D:\tmp\cc> & C:/Python/Python310/python.exe d:/tmp/cc/test.py
[ERROR] [01] - Не передан аргумент для запуска скрипта:
PS D:\tmp\cc> & C:/Python/Python310/python.exe d:/tmp/cc/test.py test1.json
[ERROR] [04] - Содержимое не является JSON или YAML: test1.json
PS D:\tmp\cc> & C:/Python/Python310/python.exe d:/tmp/cc/test.py test_err.json
[ERROR] [05] - Проблема в JSON: Expecting ':' delimiter: line 11 column 14 (char 174)
PS D:\tmp\cc> & C:/Python/Python310/python.exe d:/tmp/cc/test.py test-1.json  
PS D:\tmp\cc> & C:/Python/Python310/python.exe d:/tmp/cc/test.py test1.yml    
[ERROR] [04] - Содержимое не является JSON или YAML: test1.yml
PS D:\tmp\cc> & C:/Python/Python310/python.exe d:/tmp/cc/test.py test-1.yml   
PS D:\tmp\cc> 
```

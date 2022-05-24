
### Как сдавать задания

Вы уже изучили блок «Системы управления версиями», и начиная с этого занятия все ваши работы будут приниматься ссылками на .md-файлы, размещённые в вашем публичном репозитории.

Скопируйте в свой .md-файл содержимое этого файла; исходники можно посмотреть [здесь](https://raw.githubusercontent.com/netology-code/sysadm-homeworks/devsys10/04-script-02-py/README.md). Заполните недостающие части документа решением задач (заменяйте `???`, ОСТАЛЬНОЕ В ШАБЛОНЕ НЕ ТРОГАЙТЕ чтобы не сломать форматирование текста, подсветку синтаксиса и прочее, иначе можно отправиться на доработку) и отправляйте на проверку. Вместо логов можно вставить скриншоты по желани.

# Домашнее задание к занятию "4.2. Использование Python для решения типовых DevOps задач"

## Обязательная задача 1

Есть скрипт:
```python
#!/usr/bin/env python3
a = 1
b = '2'
c = a + b
```

### Вопросы:
| Вопрос  | Ответ |
| ------------- | ------------- |
| Какое значение будет присвоено переменной `c`?  | Никакое. Выйдет ошибка о несовместимости типов.  |
| Как получить для переменной `c` значение 12?  | c = str(a) + b  |
| Как получить для переменной `c` значение 3?  | c = a + int(b)  |

## Обязательная задача 2
Мы устроились на работу в компанию, где раньше уже был DevOps Engineer. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории, относительно локальных изменений. Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?

```python
#!/usr/bin/env python3

import os

bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
        break
```

### Ваш скрипт:
```python
#!/usr/bin/env python3

import os

GIT_DIR = '/home/antigen/tmp/test'
bash_command = [f'cd {GIT_DIR}', "git status"]
result_os = os.popen(' && '.join(bash_command)).read()

for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(os.path.join(GIT_DIR ,prepare_result))
```

### Вывод скрипта при запуске при тестировании:
```
antigen@kenny:~/tmp$ ./t.py
/home/antigen/tmp/test/1
/home/antigen/tmp/test/30
```

## Обязательная задача 3
1. Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий в текущей директории, а также умел воспринимать путь к репозиторию, который мы передаём как входной параметр. Мы точно знаем, что начальство коварное и будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import os
from sys import argv


if len(argv) == 1:
    GIT_DIRS = ['/home/antigen/tmp/test']
else:
    GIT_DIRS = argv[1:]

for git_dir in GIT_DIRS:
    print('-'*50)

    if not os.path.exists(git_dir):
        print(f'Каталога не существует: {git_dir}')
    elif os.path.isfile(git_dir):
        print(f'Не является каталогом: {git_dir}')
    elif not os.path.exists(os.path.join(git_dir, '.git')):
        print(f'Каталог не содержит .git: {git_dir}')
    else:
        bash_command = [f'cd {git_dir}', "git status"]
        result_os = os.popen(' && '.join(bash_command)).read()
        print(f'Репозиторий: {git_dir}\n')
        print('Измененные файлы: ')
        for result in result_os.split('\n'):
            if result.find('modified') != -1:
                prepare_result = result.replace('\tmodified:   ', '')
                print(os.path.join(git_dir ,prepare_result))
    continue
print('-'*50, '\n')
```

### Вывод скрипта при запуске при тестировании:
```
antigen@kenny:~/tmp$ ./t.py
--------------------------------------------------
Репозиторий: /home/antigen/tmp/test

Измененные файлы:
/home/antigen/tmp/test/1
/home/antigen/tmp/test/30
--------------------------------------------------

antigen@kenny:~/tmp$ ./t.py /home/antigen/tmp/ /home/antigen/tmp/test/ /qwqweq/qwrrew/q /home/antigen/tmp/t.py
--------------------------------------------------
Каталог не содержит .git: /home/antigen/tmp/
--------------------------------------------------
Репозиторий: /home/antigen/tmp/test/

Измененные файлы:
/home/antigen/tmp/test/1
/home/antigen/tmp/test/30
--------------------------------------------------
Каталога не существует: /qwqweq/qwrrew/q
--------------------------------------------------
Не является каталогом: /home/antigen/tmp/t.py
--------------------------------------------------
```

## Обязательная задача 4
1. Наша команда разрабатывает несколько веб-сервисов, доступных по http. Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис. Проблема в том, что отдел, занимающийся нашей инфраструктурой очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. Мы хотим написать скрипт, который опрашивает веб-сервисы, получает их IP, выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>. Также, должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена - оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка реализовала сервисы: `drive.google.com`, `mail.google.com`, `google.com`.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import socket
import os
import json


FILE = 'last_ip.txt'
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


def get_last_service_ip_dict(file_name: str) -> dict:
    with open(file_name, 'r') as f:
        result = json.loads(f.read())
    return result


def set_new_service_ip(file_name: str, service_dict: dict):
    with open(file_name, 'w') as f:
        f.write(json.dumps(service_dict))


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

    if not os.path.exists(FILE):
        set_new_service_ip(FILE, service_dict_new)
        exit()

    service_dict_last = get_last_service_ip_dict(FILE)

    print_service(service_dict_new)
    print('-'*50)

    check_result = service_check(SERVICES, service_dict_new, service_dict_last)
    if not check_result:
        set_new_service_ip(FILE, service_dict_new)
```

### Вывод скрипта при запуске при тестировании:
```
antigen@kenny:~/tmp$ ./s.py
drive.google.com - 173.194.73.194
mail.google.com - 142.251.1.83
google.com - 64.233.165.138
--------------------------------------------------
[ERROR] mail.google.com IP mismatch: 142.251.1.19 142.251.1.83
[ERROR] google.com IP mismatch: 64.233.165.113 64.233.165.138
antigen@kenny:~/tmp$
antigen@kenny:~/tmp$ ./s.py
drive.google.com - 173.194.73.194
mail.google.com - 142.251.1.83
google.com - 64.233.165.138
--------------------------------------------------
antigen@kenny:~/tmp$
antigen@kenny:~/tmp$ ./s.py
drive.google.com - 173.194.73.194
mail.google.com - 142.251.1.83
google.com - 142.251.1.113
--------------------------------------------------
[ERROR] google.com IP mismatch: 64.233.165.138 142.251.1.113
```

## Дополнительное задание (со звездочкой*) - необязательно к выполнению

Так получилось, что мы очень часто вносим правки в конфигурацию своей системы прямо на сервере. Но так как вся наша команда разработки держит файлы конфигурации в github и пользуется gitflow, то нам приходится каждый раз переносить архив с нашими изменениями с сервера на наш локальный компьютер, формировать новую ветку, коммитить в неё изменения, создавать pull request (PR) и только после выполнения Merge мы наконец можем официально подтвердить, что новая конфигурация применена. Мы хотим максимально автоматизировать всю цепочку действий. Для этого нам нужно написать скрипт, который будет в директории с локальным репозиторием обращаться по API к github, создавать PR для вливания текущей выбранной ветки в master с сообщением, которое мы вписываем в первый параметр при обращении к py-файлу (сообщение не может быть пустым). При желании, можно добавить к указанному функционалу создание новой ветки, commit и push в неё изменений конфигурации. С директорией локального репозитория можно делать всё, что угодно. Также, принимаем во внимание, что Merge Conflict у нас отсутствуют и их точно не будет при push, как в свою ветку, так и при слиянии в master. Важно получить конечный результат с созданным PR, в котором применяются наши изменения. 

### Ваш скрипт:
```python
???
```

### Вывод скрипта при запуске при тестировании:
```
???
```

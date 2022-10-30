# Домашнее задание к занятию "08.04 Создание собственных modules"

## Подготовка к выполнению
1. Создайте пустой публичных репозиторий в любом своём проекте: `my_own_collection`
2. Скачайте репозиторий ansible: `git clone https://github.com/ansible/ansible.git` по любому удобному вам пути
3. Зайдите в директорию ansible: `cd ansible`
4. Создайте виртуальное окружение: `python3 -m venv venv`
5. Активируйте виртуальное окружение: `. venv/bin/activate`. Дальнейшие действия производятся только в виртуальном окружении
6. Установите зависимости `pip install -r requirements.txt`
7. Запустить настройку окружения `. hacking/env-setup`
8. Если все шаги прошли успешно - выйти из виртуального окружения `deactivate`
9. Ваше окружение настроено, для того чтобы запустить его, нужно находиться в директории `ansible` и выполнить конструкцию `. venv/bin/activate && . hacking/env-setup`

## Основная часть

Наша цель - написать собственный module, который мы можем использовать в своей role, через playbook. Всё это должно быть собрано в виде collection и отправлено в наш репозиторий.

1. В виртуальном окружении создать новый `my_own_module.py` файл
2. Наполнить его содержимым:
```python
#!/usr/bin/python

# Copyright: (c) 2018, Terry Jones <terry.jones@example.org>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: my_test

short_description: This is my test module

# If this is part of a collection, you need to use semantic versioning,
# i.e. the version is of the form "2.5.0" and not "2.4".
version_added: "1.0.0"

description: This is my longer description explaining my test module.

options:
    name:
        description: This is the message to send to the test module.
        required: true
        type: str
    new:
        description:
            - Control to demo if the result of this module is changed or not.
            - Parameter description can be a list as well.
        required: false
        type: bool
# Specify this value according to your collection
# in format of namespace.collection.doc_fragment_name
extends_documentation_fragment:
    - my_namespace.my_collection.my_doc_fragment_name

author:
    - Your Name (@yourGitHubHandle)
'''

EXAMPLES = r'''
# Pass in a message
- name: Test with a message
  my_namespace.my_collection.my_test:
    name: hello world

# pass in a message and have changed true
- name: Test with a message and changed output
  my_namespace.my_collection.my_test:
    name: hello world
    new: true

# fail the module
- name: Test failure of the module
  my_namespace.my_collection.my_test:
    name: fail me
'''

RETURN = r'''
# These are examples of possible return values, and in general should use other names for return values.
original_message:
    description: The original name param that was passed in.
    type: str
    returned: always
    sample: 'hello world'
message:
    description: The output message that the test module generates.
    type: str
    returned: always
    sample: 'goodbye'
'''

from ansible.module_utils.basic import AnsibleModule


def run_module():
    # define available arguments/parameters a user can pass to the module
    module_args = dict(
        name=dict(type='str', required=True),
        new=dict(type='bool', required=False, default=False)
    )

    # seed the result dict in the object
    # we primarily care about changed and state
    # changed is if this module effectively modified the target
    # state will include any data that you want your module to pass back
    # for consumption, for example, in a subsequent task
    result = dict(
        changed=False,
        original_message='',
        message=''
    )

    # the AnsibleModule object will be our abstraction working with Ansible
    # this includes instantiation, a couple of common attr would be the
    # args/params passed to the execution, as well as if the module
    # supports check mode
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    # if the user is working with this module in only check mode we do not
    # want to make any changes to the environment, just return the current
    # state with no modifications
    if module.check_mode:
        module.exit_json(**result)

    # manipulate or modify the state as needed (this is going to be the
    # part where your module will do what it needs to do)
    result['original_message'] = module.params['name']
    result['message'] = 'goodbye'

    # use whatever logic you need to determine whether or not this module
    # made any modifications to your target
    if module.params['new']:
        result['changed'] = True

    # during the execution of the module, if there is an exception or a
    # conditional state that effectively causes a failure, run
    # AnsibleModule.fail_json() to pass in the message and the result
    if module.params['name'] == 'fail me':
        module.fail_json(msg='You requested this to fail', **result)

    # in the event of a successful module execution, you will want to
    # simple AnsibleModule.exit_json(), passing the key/value results
    module.exit_json(**result)


def main():
    run_module()


if __name__ == '__main__':
    main()
```
Или возьмите данное наполнение из [статьи](https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_general.html#creating-a-module).

3. Заполните файл в соответствии с требованиями ansible так, чтобы он выполнял основную задачу: module должен создавать текстовый файл на удалённом хосте по пути, определённом в параметре `path`, с содержимым, определённым в параметре `content`.
4. Проверьте module на исполняемость локально.
5. Напишите single task playbook и используйте module в нём.
6. Проверьте через playbook на идемпотентность.
7. Выйдите из виртуального окружения.
8. Инициализируйте новую collection: `ansible-galaxy collection init my_own_namespace.yandex_cloud_elk`
9. В данную collection перенесите свой module в соответствующую директорию.
10. Single task playbook преобразуйте в single task role и перенесите в collection. У role должны быть default всех параметров module
11. Создайте playbook для использования этой role.
12. Заполните всю документацию по collection, выложите в свой репозиторий, поставьте тег `1.0.0` на этот коммит.
13. Создайте .tar.gz этой collection: `ansible-galaxy collection build` в корневой директории collection.
14. Создайте ещё одну директорию любого наименования, перенесите туда single task playbook и архив c collection.
15. Установите collection из локального архива: `ansible-galaxy collection install <archivename>.tar.gz`
16. Запустите playbook, убедитесь, что он работает.
17. В ответ необходимо прислать ссылку на репозиторий с collection

### Ответ
3. Листинг  `/opt/docker/molecule/6/ansible/lib/ansible/modules/ my_own_module.py`
```python
#!/usr/bin/python3

# Copyright: (c) 2018, Terry Jones <terry.jones@example.org>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: my_test

short_description: This is my test module

# If this is part of a collection, you need to use semantic versioning,
# i.e. the version is of the form "2.5.0" and not "2.4".
version_added: "1.0.0"

description: This is my longer description explaining my test module.

options:
    name:
        description: This is the message to send to the test module.
        required: true
        type: str
    new:
        description:
            - Control to demo if the result of this module is changed or not.
            - Parameter description can be a list as well.
        required: false
        type: bool
# Specify this value according to your collection
# in format of namespace.collection.doc_fragment_name
extends_documentation_fragment:
    - my_namespace.my_collection.my_doc_fragment_name

author:
    - Ramil (@antigen2)
'''

EXAMPLES = r'''
# Pass in a message
- name: Test with a message
  my_namespace.my_collection.my_test:
    name: hello world

# pass in a message and have changed true
- name: Test with a message and changed output
  my_namespace.my_collection.my_test:
    name: hello world
    new: true

# fail the module
- name: Test failure of the module
  my_namespace.my_collection.my_test:
    name: fail me
'''

RETURN = r'''
# These are examples of possible return values, and in general should use other names for return values.
original_message:
    description: The original name param that was passed in.
    type: str
    returned: always
    sample: 'hello world'
message:
    description: The output message that the test module generates.
    type: str
    returned: always
    sample: 'goodbye'
'''

from ansible.module_utils.basic import AnsibleModule
import os


def run_module():
    # define available arguments/parameters a user can pass to the module
    module_args = dict(
        path=dict(type='str', required=True),
        content=dict(type='str', required=False, default='')
    )

    # seed the result dict in the object
    # we primarily care about changed and state
    # changed is if this module effectively modified the target
    # state will include any data that you want your module to pass back
    # for consumption, for example, in a subsequent task
    result = dict(
        changed=False,
        path='',
        content=''
    )

    # the AnsibleModule object will be our abstraction working with Ansible
    # this includes instantiation, a couple of common attr would be the
    # args/params passed to the execution, as well as if the module
    # supports check mode
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    # if the user is working with this module in only check mode we do not
    # want to make any changes to the environment, just return the current
    # state with no modifications
    if module.check_mode:
        module.exit_json(**result)

    # manipulate or modify the state as needed (this is going to be the
    # part where your module will do what it needs to do)
    result['path'] = module.params['path']
    result['content'] = module.params['content']

    go_write = False
    result['path'] = module.params['path']
    if os.path.isfile(result['path']):
        try:
            with open(result['path'],'r') as f:
                data = f.read()
        except:
            module.fail_json(msg='Can`t open file. Check file path and access rights.', **result)
        if result['content'] == '':
            result['content'] = data
            result['status'] = 'readed'
        elif data == result['content']:
            result['status'] = 'resisted'
        else:
            result['status'] = 'modified'
            go_write = True
    elif not os.path.exists(result['path']):
        result['status'] = 'created'
        go_write = True
    else:
        module.fail_json(msg='Path is directory.', **result)

    if go_write:
        result['changed'] = True
        if not module.check_mode:
            try:
                with open(result['path'],'w') as f:
                    f.write(result['content'])
            except:
                result['status'] = 'denied'
                module.fail_json(msg='Can`t write to file. Check file path and access rights.', **result)


    # in the event of a successful module execution, you will want to
    # simple AnsibleModule.exit_json(), passing the key/value results
    module.exit_json(**result)


def main():
    run_module()


if __name__ == '__main__':
    main()
```
4. Создаем `json` файл для тестового запуска модуля. Листинг `1.json`:
```json
{
  "ANSIBLE_MODULE_ARGS": {
    "path": "test_path",
    "content": "my first test line"
  }
}
```
Запускаем проверку:
```bash
(venv) mbadmin@docker1:/opt/docker/molecule/6/ansible$ chmod +x my_own_module.py
(venv) mbadmin@docker1:/opt/docker/molecule/6/ansible$ ./my_own_module.py 1.json

{"changed": true, "path": "test_path", "content": "my first test line", "status": "created", "uid": 1000, "gid": 1000, "owner": "mbadmin", "group": "mbadmin", "mode": "0644", "state": "file", "size": 18, "invocation": {"module_args": {"path": "test_path", "content": "my first test line"}}}
(venv) mbadmin@docker1:/opt/docker/molecule/6/ansible$ ls -lah test_*
-rw-r--r-- 1 mbadmin mbadmin 18 окт 30 17:59 test_path
```
При повторном запуске:
```bash
(venv) mbadmin@docker1:/opt/docker/molecule/6/ansible$ ./my_own_module.py 1.json

{"changed": false, "path": "test_path", "content": "my first test line", "status": "resisted", "uid": 1000, "gid": 1000, "owner": "mbadmin", "group": "mbadmin", "mode": "0644", "state": "file", "size": 18, "invocation": {"module_args": {"path": "test_path", "content": "my first test line"}}}
```
5. Листинг `test.yml`:
```yaml
---
- name: Test module
  hosts: localhost
  tasks:
    - name: Create test_path
      my_own_module:
        path: test_path
        content: my first test line
```
6. Запускаем первый раз:
```bash
(venv) mbadmin@docker1:/opt/docker/molecule/6/ansible$ ansible-playbook test.yml
[WARNING]: You are running the development version of Ansible. You should only run Ansible from "devel" if you are modifying the Ansible engine, or trying out
features under development. This is a rapidly changing source of code and can become unstable at any point.
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [Test module] **************************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************
ok: [localhost]

TASK [Create test_path] *********************************************************************************************************************************************
changed: [localhost]

PLAY RECAP **********************************************************************************************************************************************************
localhost                  : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
Запускаем повторно:
```bash
(venv) mbadmin@docker1:/opt/docker/molecule/6/ansible$ ansible-playbook test.yml
[WARNING]: You are running the development version of Ansible. You should only run Ansible from "devel" if you are modifying the Ansible engine, or trying out
features under development. This is a rapidly changing source of code and can become unstable at any point.
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [Test module] **************************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************
ok: [localhost]

TASK [Create test_path] *********************************************************************************************************************************************
ok: [localhost]

PLAY RECAP **********************************************************************************************************************************************************
localhost                  : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
7. `deactivate`
8. Инициализируем новую `collection`. Заменю название коллекции на своё: `antigen2.tools`
```bash
mbadmin@docker1:/opt/docker/molecule/6$ ansible-galaxy collection init antigen2.tools
- Collection antigen2.tools was created successfully
```
9. Скопировал файл в `plugins\modules`
10. Ссылка на single task role в collection: [my_own_modoule](https://github.com/antigen2/my_own_collection/tree/master/roles/my_own_module)
11. Ссылка на playbook в репозитории: [test_my_own_modoule.yml](https://github.com/antigen2/my_own_collection/blob/master/playbooks/test_my_own_module.yml)
12. [Ссылка на репозиторий](https://github.com/antigen2/my_own_collection)
13. Архив
```bash
antigen@gramm:~/netology/tmp/modules/my_own_collection$ ansible-galaxy collection build
Created collection for antigen2.tools at /home/antigen/netology/tmp/modules/my_own_collection/antigen2-tools-1.0.0.tar.gz
```
14. Новый каталог
```bash
antigen@gramm:~/netology/tmp/test$ ls -lah
итого 20K
drwxr-xr-x 2 antigen antigen 4,0K окт 30 21:32 .
drwxr-xr-x 9 antigen antigen 4,0K окт 30 21:31 ..
-rw-r--r-- 1 antigen antigen 7,9K окт 30 21:23 antigen2-tools-1.0.0.tar.gz
-rw-r--r-- 1 antigen antigen   99 окт 30 19:56 test_my_own_module.yml
```
15. Установка из архива
```bash
antigen@gramm:~/netology/tmp/test$ ansible-galaxy collection install antigen2-tools-1.0.0.tar.gz 
Starting galaxy collection install process
Process install dependency map
Starting collection install process
Installing 'antigen2.tools:1.0.0' to '/home/antigen/.ansible/collections/ansible_collections/antigen2/tools'
antigen2.tools:1.0.0 was installed successfully
```
16. Запуск `playbook`
```bash
antigen@gramm:~/netology/tmp/test$ ansible-playbook test_my_own_module.yml 
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [Test file content role] ******************************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************************
ok: [localhost]

TASK [my_own_module : Create file] *************************************************************************************************************************************************************************************
changed: [localhost]

PLAY RECAP *************************************************************************************************************************************************************************************************************
localhost                  : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 

antigen@gramm:~/netology/tmp/test$ ls
antigen2-tools-1.0.0.tar.gz  test_file  test_my_own_module.yml
```
17. [Ссылка на репозиторий](https://github.com/antigen2/my_own_collection)

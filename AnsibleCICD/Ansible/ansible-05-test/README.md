# Домашнее задание к занятию "08.05 Тестирование Roles"

## Подготовка к выполнению
1. Установите molecule: `pip3 install "molecule==3.5.2"`
2. Выполните `docker pull aragast/netology:latest` -  это образ с podman, tox и несколькими пайтонами (3.7 и 3.9) внутри

## Основная часть

Наша основная цель - настроить тестирование наших ролей. Задача: сделать сценарии тестирования для vector. Ожидаемый результат: все сценарии успешно проходят тестирование ролей.

### Molecule

1. Запустите  `molecule test -s centos8` внутри корневой директории clickhouse-role, посмотрите на вывод команды.
2. Перейдите в каталог с ролью vector-role и создайте сценарий тестирования по умолчанию при помощи `molecule init scenario --driver-name docker`.
3. Добавьте несколько разных дистрибутивов (centos:8, ubuntu:latest) для инстансов и протестируйте роль, исправьте найденные ошибки, если они есть.
4. Добавьте несколько assert'ов в verify.yml файл для  проверки работоспособности vector-role (проверка, что конфиг валидный, проверка успешности запуска, etc). Запустите тестирование роли повторно и проверьте, что оно прошло успешно.
5. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.

#### Ответ
1.
```bash
antigen@gramm:~/netology/devops-netology/AnsibleCICD/Ansible/ansible-05-test/src/clickhouse_role$ molecule init scenario centos8 --driver-name docker      
INFO     Initializing new scenario centos8...
INFO     Initialized scenario in /home/antigen/netology/devops-netology/AnsibleCICD/Ansible/ansible-05-test/src/clickhouse_role/molecule/centos8 successfully.
```
Листинг `molecule/centos8/molecule.yaml`:
```yaml
---
dependency:
  name: galaxy

driver:
  name: docker
  options:
    D: true
    vv: true

lint: |
  yamllint .
  ansible-lint .

platforms:
  - name: centos8
    image: docker.io/pycontribs/centos:8
    pre_build_image: true
provisioner:
  name: ansible
verifier:
  name: ansible
```
```bash
molecule test -s centos8
```
2. 
```bash
molecule init scenario --driver-name docker
```
3. Листинг `vector_role/molecule/default/molecule.yml`
```yaml
---
dependency:
  name: galaxy
driver:
  name: docker
platforms:
  - name: centos8
    image: docker.io/pycontribs/centos:8
    pre_build_image: true
  - name: ubuntu
    image: docker.io/pycontribs/ubuntu:latest
    pre_build_image: true
provisioner:
  name: ansible
verifier:
  name: ansible
```
4. Листинг `vector_role/molecule/default/verify.yml`
```yaml
---
# This is an example playbook to execute Ansible tests.

- name: Verify
  hosts: all
  gather_facts: false
  vars:
    vector_config_path: /etc/vector/vector.yaml
  tasks:
  - name: Get Vector version
    ansible.builtin.command: "vector --version"
    changed_when: false
    register: vector_version
  - name: Assert Vector instalation
    assert:
      that: "'{{ vector_version.rc }}' == '0'"

  - name: Validation Vector configuration
    ansible.builtin.command: "vector validate --no-environment --config-yaml {{ vector_config_path }}"
    changed_when: false
    register: vector_validate
  - name: Assert Vector validate config
    assert:
      that: "'{{ vector_validate.rc }}' == '0'"
```
5. [Tag 1.2.0](https://github.com/antigen2/vector-role/tree/1.2.0)


### Tox

1. Добавьте в директорию с vector-role файлы из [директории](./example)
2. Запустите `docker run --privileged=True -v <path_to_repo>:/opt/vector-role -w /opt/vector-role -it aragast/netology:latest /bin/bash`, где path_to_repo - путь до корня репозитория с vector-role на вашей файловой системе.
3. Внутри контейнера выполните команду `tox`, посмотрите на вывод.
5. Создайте облегчённый сценарий для `molecule` с драйвером `molecule_podman`. Проверьте его на исполнимость.
6. Пропишите правильную команду в `tox.ini` для того чтобы запускался облегчённый сценарий.
8. Запустите команду `tox`. Убедитесь, что всё отработало успешно.
9. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.

После выполнения у вас должно получится два сценария molecule и один tox.ini файл в репозитории. Ссылка на репозиторий являются ответами на домашнее задание. Не забудьте указать в ответе теги решений Tox и Molecule заданий.

#### Ответ
2. 
```bash
docker run --privileged=True -v /home/antigen/netology/devops-netology/AnsibleCICD/Ansible/ansible-05-test/src/vector_role:/opt/vector-role -w /opt/vector-role -it aragast/netology:latest /bin/bash
```
5. 
```bash
molecule init scenario --driver-name podman podman
```
6. 
```ini
[tox]
minversion = 1.8
basepython = python3.6
envlist = py{37,39}-ansible{210,30}
skipsdist = true

[testenv]
passenv = *
deps =
    -r tox-requirements.txt
    ansible210: ansible<3.0
    ansible30: ansible<3.1
commands =
    {posargs:molecule test -s podman --destroy always}
```
[Tag 1.3.0](https://github.com/antigen2/vector-role/tree/1.3.0)

# Домашнее задание к занятию "08.01 Введение в Ansible"

## Подготовка к выполнению
1. Установите ansible версии 2.10 или выше.
2. Создайте свой собственный публичный репозиторий на github с произвольным именем.
3. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.

## Основная часть
1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте какое значение имеет факт `some_fact` для указанного хоста при выполнении playbook'a.
2. Найдите файл с переменными (group_vars) в котором задаётся найденное в первом пункте значение и поменяйте его на 'all default fact'.
3. Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.
4. Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.
5. Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились следующие значения: для `deb` - 'deb default fact', для `el` - 'el default fact'.
6.  Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.
7. При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.
8. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь в работоспособности.
9. Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.
10. В `prod.yml` добавьте новую группу хостов с именем  `local`, в ней разместите localhost с необходимым типом подключения.
11. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь что факты `some_fact` для каждого из хостов определены из верных `group_vars`.
12. Заполните `README.md` ответами на вопросы. Сделайте `git push` в ветку `master`. В ответе отправьте ссылку на ваш открытый репозиторий с изменённым `playbook` и заполненным `README.md`.

### Ответ

1. 
```bash
antigen@kenny:~/my/09/src/playbook$ ansible-playbook -i inventory/test.yml site.yml --start-at-task "Print fact"

PLAY [Print os facts] ***********************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************
ok: [localhost]

TASK [Print fact] ***************************************************************************************************************************************************
ok: [localhost] => {
    "msg": 12
}

PLAY RECAP **********************************************************************************************************************************************************
localhost                  : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
`12`
2. 
```bash
antigen@kenny:~/my/09/src/playbook$ cat group_vars/all/examp.yml
---
  some_fact: "all default fact"
```
3. Dockerfile
Листинг `docker.yml`:
```yaml
---
- hosts: all
  vars:
    container_image:
      - centos:7
      - ubuntu:20.04
    container_command: sleep infinity

  tasks:

    - name: Pull Docker Image
      community.docker.docker_image:
        name: "{{ item }}"
        source: pull
      loop: "{{ container_image }}"

    - name: Create container
      community.docker.docker_container:
        name: "{{ item.split(':')[0] }}"
        image: "{{ item }}"
        state: started
        command: "{{ container_command }}"
      loop: "{{ container_image }}"

    - name: Rename centos container
      shell: docker rename centos centos7
```
```bash
antigen@kenny:~/my/09/src$ ansible-playbook -i playbook/inventory/test.yml docker.yml
```
```bash
antigen@kenny:~/my/09/src$ docker images
REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
ubuntu       20.04     a0ce5a295b63   11 days ago     72.8MB
centos       7         eeb6ee3f44bd   12 months ago   204MB
antigen@kenny:~/my/09/src$ docker ps -a
CONTAINER ID   IMAGE          COMMAND            CREATED          STATUS          PORTS     NAMES
f14f4974fe6b   ubuntu:20.04   "sleep infinity"   45 minutes ago   Up 45 minutes             ubuntu
360ac746e6a1   centos:7       "sleep infinity"   45 minutes ago   Up 45 minutes             centos7
```
Листинг `install_py3.yml`:
```yaml
---
- hosts: all
  gather_facts: no
  vars:
    pkg: python3

  tasks:

    - name: Check for Python
      raw: test -e /usr/bin/python3
      changed_when: false
      failed_when: false
      register: check_python

    - name: Install Python
      raw: test -e /usr/bin/apt && (apt -y update && apt install -y {{ pkg }}) || (yum -y install {{ pkg }})
      when: check_python.rc != 0
```
```bash
antigen@kenny:~/my/09/src$ ansible-playbook -i playbook/inventory/prod.yml install_py3.yml

PLAY [all] ********************************************************************************************************************************************************************************

TASK [Check for Python] *******************************************************************************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Install Python] *********************************************************************************************************************************************************************
skipping: [centos7]
changed: [ubuntu]

PLAY RECAP ********************************************************************************************************************************************************************************
centos7                    : ok=1    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
ubuntu                     : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
4. 
```bash
antigen@kenny:~/my/09/src/playbook$ ansible-playbook -i inventory/prod.yml site.yml

PLAY [Print os facts] *********************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ***************************************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] *************************************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "el"
}
ok: [ubuntu] => {
    "msg": "deb"
}

PLAY RECAP ********************************************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
`ok: [centos7] => {"msg": "el"}`
`ok: [ubuntu] => {"msg": "deb"}`
5. 
```bash
antigen@kenny:~/my/09/src/playbook$ cat group_vars/{deb,el}/examp.yml
---
  some_fact: "deb default fact"
---
  some_fact: "el default fact"
```
6. 
```bash
antigen@kenny:~/my/09/src/playbook$ ansible-playbook -i inventory/prod.yml site.yml

PLAY [Print os facts] *********************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ***************************************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] *************************************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP ********************************************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
7. 
```bash
antigen@kenny:~/my/09/src/playbook$ ansible-vault encrypt group_vars/{deb,el}/examp.yml
New Vault password:
Confirm New Vault password:
Encryption successful
```
8. 
```bash
antigen@kenny:~/my/09/src/playbook$ ansible-playbook --ask-vault-pass -i inventory/prod.yml site.yml
Vault password:

PLAY [Print os facts] *********************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ***************************************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] *************************************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP ********************************************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
9. 
```bash
antigen@kenny:~/my/09/src/playbook$ ansible-doc -t connection -l
ansible.netcommon.grpc         Provides a persistent connection using the gRPC protocol
ansible.netcommon.httpapi      Use httpapi to run command on network appliances
ansible.netcommon.libssh       (Tech preview) Run tasks using libssh for ssh connection
ansible.netcommon.napalm       Provides persistent connection using NAPALM
ansible.netcommon.netconf      Provides a persistent connection using the netconf protocol
ansible.netcommon.network_cli  Use network_cli to run command on network appliances
ansible.netcommon.persistent   Use a persistent unix socket for connection
community.aws.aws_ssm          execute via AWS Systems Manager
community.docker.docker        Run tasks in docker containers
community.docker.docker_api    Run tasks in docker containers
community.docker.nsenter       execute on host running controller container
community.general.chroot       Interact with local chroot
community.general.funcd        Use funcd to connect to target
community.general.iocage       Run tasks in iocage jails
community.general.jail         Run tasks in jails
community.general.lxc          Run tasks in lxc containers via lxc python library
community.general.lxd          Run tasks in lxc containers via lxc CLI
community.general.qubes        Interact with an existing QubesOS AppVM
community.general.saltstack    Allow ansible to piggyback on salt minions
community.general.zone         Run tasks in a zone instance
community.libvirt.libvirt_lxc  Run tasks in lxc containers via libvirt
community.libvirt.libvirt_qemu Run tasks on libvirt/qemu virtual machines
community.okd.oc               Execute tasks in pods running on OpenShift
community.vmware.vmware_tools  Execute tasks inside a VM via VMware Tools
community.zabbix.httpapi       Use httpapi to run command on network appliances
containers.podman.buildah      Interact with an existing buildah container
containers.podman.podman       Interact with an existing podman container
kubernetes.core.kubectl        Execute tasks in pods running on Kubernetes
local                          execute on controller
paramiko_ssh                   Run tasks via python ssh (paramiko)
psrp                           Run tasks over Microsoft PowerShell Remoting Protocol
ssh                            connect via SSH client binary
winrm                          Run tasks over Microsoft's WinRM
```
`local                          execute on controller`
10. 
```bash
antigen@kenny:~/my/09/src/playbook$ cat inventory/prod.yml
---
  el:
    hosts:
      centos7:
        ansible_connection: docker
  deb:
    hosts:
      ubuntu:
        ansible_connection: docker

  local:
    hosts:
      localhost:
        ansible_connection: local
```
11. 
```bash
antigen@kenny:~/my/09/src/playbook$ ansible-playbook --ask-vault-pass -i inventory/prod.yml site.yml
Vault password:

PLAY [Print os facts] *********************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************
ok: [localhost]
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ***************************************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] *************************************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [localhost] => {
    "msg": "all default fact"
}

PLAY RECAP ********************************************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
12. (Ссылка)[]
## Необязательная часть

1. При помощи `ansible-vault` расшифруйте все зашифрованные файлы с переменными.
2. Зашифруйте отдельное значение `PaSSw0rd` для переменной `some_fact` паролем `netology`. Добавьте полученное значение в `group_vars/all/exmp.yml`.
3. Запустите `playbook`, убедитесь, что для нужных хостов применился новый `fact`.
4. Добавьте новую группу хостов `fedora`, самостоятельно придумайте для неё переменную. В качестве образа можно использовать [этот](https://hub.docker.com/r/pycontribs/fedora).
5. Напишите скрипт на bash: автоматизируйте поднятие необходимых контейнеров, запуск ansible-playbook и остановку контейнеров.
6. Все изменения должны быть зафиксированы и отправлены в вашей личный репозиторий.

### Ответ
1. 
```bash
antigen@kenny:~/my/09/src/playbook$ cat group_vars/{deb,el}/examp.yml
$ANSIBLE_VAULT;1.1;AES256
31346562363033313464343638373135653763313131663463643235663433386339363563656535
6339623334656336383033306438323832313733373765610a633033666463353166373636386539
37613437346334303635396535646565633761323561376262353938323236653263333664623231
6139366232373164380a396536353836303534346139346634616436373834326637353065366435
38613463636537383233383265343031303861613561346531353634346530653537343365303532
3337303731666364343230626634366332376538343730316637
$ANSIBLE_VAULT;1.1;AES256
65653234623631613633666137336136343131303430366330396235356436373933373535613135
6262373061383836393333326330306234363239653931360a353631643839356364353963623535
32353061383930353539303137373238653334363731396536666334346537386131343839613039
3865366136373539660a323136643838326161343764313566663062396632666336346635373065
65363432343531373331373366326663303965336661616665353934326161373464616463303435
6339373932383735636338386263666235626535613166306631
antigen@kenny:~/my/09/src/playbook$ ansible-vault decrypt group_vars/{deb,el}/examp.yml
Vault password:
Decryption successful
antigen@kenny:~/my/09/src/playbook$ cat group_vars/{deb,el}/examp.yml
---
  some_fact: "deb default fact"
---
  some_fact: "el default fact"
```
2. 
```bash
antigen@kenny:~/my/09/src/playbook$ echo "some_fact: PaSSw0rd" > group_vars/all/var.xml
antigen@kenny:~/my/09/src/playbook$ ansible-vault encrypt group_vars/all/var.xml
antigen@kenny:~/my/09/src/playbook$ cat group_vars/all/examp.yml
---
  some_fact: "{{ var_some_fact }}"
antigen@kenny:~/my/09/src/playbook$ cat group_vars/all/var.yml
$ANSIBLE_VAULT;1.1;AES256
62633038306132336266653663653737393736666564316264323164326434303865626137303331
6662613631333934643030323233616231613065393732330a326334323465363336386461653830
31336463396230306133653264306663333738356366323434306331303939316337653137353662
3035313864313933630a653361326339376433653338643564343161353135373532363932323836
61613439646263653234393863373565366537623434646163363162376634373061
```
3. 
```bash
antigen@kenny:~/my/09/src/playbook$ ansible-playbook --ask-vault-pass -i inventory/prod.yml site.yml
Vault password:

PLAY [Print os facts] *********************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************
ok: [localhost]
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ***************************************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] *************************************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [localhost] => {
    "msg": "PaSSw0rd"
}

PLAY RECAP ********************************************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
4. 


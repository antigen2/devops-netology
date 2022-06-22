
# Домашнее задание к занятию "5.2. Применение принципов IaaC в работе с виртуальными машинами"

## Задача 1

- Опишите своими словами основные преимущества применения на практике IaaC паттернов.
- Какой из принципов IaaC является основополагающим?

### Ответ

- За счет постоянного тестирования CI возможно найти быстрей в тексте кода. Благодаря CD возможно откатиться к более ранней версии продукта при появлении ошибок.
- Идемпотентность - результат выполнения операции всегда идентичный предыдущему и всем последующим выполнениям.

## Задача 2

- Чем Ansible выгодно отличается от других систем управление конфигурациями?
- Какой, на ваш взгляд, метод работы систем конфигурации более надёжный push или pull?

### Ответ

- Ansible не требует клиентов на хостах и подключается напрямую через ssh протокол.
- При небольшом количестве серверов вполне подойдет push, но когда число хостов переваливает за 100 уже имеет смысл использовать pull. Думаю, что pull все же безопаснее, т.к. ни один внешний пользователь не имеет доступа до хоста с правами администратора.

## Задача 3

Установить на личный компьютер:

- VirtualBox
- Vagrant
- Ansible

*Приложить вывод команд установленных версий каждой из программ, оформленный в markdown.*

### Ответ
```bash
antigen@gramm:~$ virtualbox --help
Oracle VM VirtualBox VM Selector v6.1.32_Debian
(C) 2005-2022 Oracle Corporation
All rights reserved.

No special options.

If you are looking for --startvm and related options, you need to use VirtualBoxVM.
```
```bash
antigen@gramm:~$ vagrant --version
Vagrant 2.2.14
```
```bash
antigen@gramm:~$ ansible --version
ansible 2.10.8
  config file = None
  configured module search path = ['/home/antigen/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 3.9.2 (default, Feb 28 2021, 17:03:44) [GCC 10.2.1 20210110]
```

## Задача 4 (*)

Воспроизвести практическую часть лекции самостоятельно.

- Создать виртуальную машину.
- Зайти внутрь ВМ, убедиться, что Docker установлен с помощью команды
```
docker ps
```
### Ответ
```bash
antigen@gramm:~/netology/devops-netology/VirtualDBTerra/Virtual/2/vagrant$ vagrant ssh
Welcome to Ubuntu 20.04.4 LTS (GNU/Linux 5.4.0-110-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

 System information disabled due to load higher than 1.0


This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento
Last login: Wed Jun 22 22:25:44 2022 from 10.0.2.2
vagrant@server1:~$ docker ps -a
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
vagrant@server1:~$ 
```

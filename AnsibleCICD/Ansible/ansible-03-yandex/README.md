# Домашнее задание к занятию "08.03 Использование Yandex Cloud"

## Подготовка к выполнению

1. (Необязательно) Познакомтесь с [lighthouse](https://youtu.be/ymlrNlaHzIY?t=929)
2. Подготовьте в Yandex Cloud три хоста: для `clickhouse`, для `vector` и для `lighthouse`.

Ссылка на репозиторий LightHouse: https://github.com/VKCOM/lighthouse

## Основная часть

1. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает lighthouse.
2. При создании tasks рекомендую использовать модули: `get_url`, `template`, `yum`, `apt`.
3. Tasks должны: скачать статику lighthouse, установить nginx или любой другой webserver, настроить его конфиг для открытия lighthouse, запустить webserver.
4. Приготовьте свой собственный inventory файл `prod.yml`.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.
6. Попробуйте запустить playbook на этом окружении с флагом `--check`.
7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.
8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
9. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.
10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-03-yandex` на фиксирующий коммит, в ответ предоставьте ссылку на него.

## Ответ

1. `play` для `lighthouse`:
```yaml
# Установка Lighthouse
- name: Install lighthouse
  hosts: lighthouse
  tags:
    - lighthouse
  handlers:
    - name: Start nginx service
      become: true
      ansible.builtin.service:
        name: nginx
        state: restarted
  pre_tasks:
    - name: Install epel-release
      become: true
      ansible.builtin.yum:
        name: epel-release
        state: present
    - name: Install Nginx
      become: true
      ansible.builtin.yum:
        name: nginx
        state: present
      notify: Start nginx service
    - name: Create Nginx config
      become: true
      ansible.builtin.template:
        src: nginx.j2
        dest: /etc/nginx/nginx.conf
        mode: 0644
      notify: Start nginx service
  roles:
    - role: lighthouse_role
  post_tasks:
    - name: Show connect URL lighthouse
      ansible.builtin.debug:
        msg: "http://{{ ansible_host }}/#http://{{ hostvars['clickhouse-01'].ansible_host }}:8123/?user={{ clickhouse_user }}"
```

4. Листинг `prod.yml`:
```yaml
---
clickhouse:
  hosts:
    clickhouse-01:
      ansible_host: 51.250.47.146
      ansible_user: cloud-user

vector:
  hosts:
    vector-01:
      ansible_host: 51.250.36.155
      ansible_user: cloud-user

lighthouse:
  hosts:
    lighthouse-01:
      ansible_host: 51.250.45.92
      ansible_user: cloud-user
```
9. Ссылка: [README.md](https://github.com/antigen2/devops-netology/blob/main/AnsibleCICD/Ansible/ansible-03-yandex/src/README.md)
10. [Ссылка]()

# Домашнее задание к занятию «Установка Kubernetes»

### Цель задания

Установить кластер K8s.

### Чеклист готовности к домашнему заданию

1. Развёрнутые ВМ с ОС Ubuntu 20.04-lts.


### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Инструкция по установке kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/).
2. [Документация kubespray](https://kubespray.io/).

-----

### Задание 1. Установить кластер k8s с 1 master node

1. Подготовка работы кластера из 5 нод: 1 мастер и 4 рабочие ноды.
2. В качестве CRI — containerd.
3. Запуск etcd производить на мастере.
4. Способ установки выбрать самостоятельно.

Сделаем файл с переменными для `terraform` `.env`:
```bash
export TF_VAR_yc_token=AQAAAAxxxxxxxxxxxxxxxxxxxxxxxt9I
export TF_VAR_yc_cloud_id=b1xxxxxxxxxxxxxxxxxxxr3d
export TF_VAR_yc_folder_id=b1xxxxxxxxxxxxxxxxxxxxcc
export TF_VAR_yc_zone=ru-central1-c
```
И применим его значения в свою среду:
```bash
antigen@deb11notepad:~/netology/12/terraform$ source .env
```
Инициализируем `yc`:
```bash
antigen@deb11notepad:~/netology/12/terraform$ yc init
```
Создаем сервис-ключ `antigen2-sa`:
```bash
antigen@deb11notepad:~/netology/12/terraform$ yc iam key create --service-account-name antigen2-sa --output key.json
```
Подготовил `terraform` и `ansible` конфигурации (лежат в `src`). Запустил сначала `terraform`:
```bash
antigen@deb11notepad:~/netology/12/terraform$ terraform init
...
antigen@deb11notepad:~/netology/12/terraform$ terraform validate
Success! The configuration is valid.
antigen@deb11notepad:~/netology/12/terraform$ terraform apply --auto-approve
...
Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:

master_instance_ips = {
  "external_ip_address" = [
    "51.250.42.158",
  ]
  "internal_ip_address" = [
    "192.168.100.6",
  ]
  "name" = [
    "master-0",
  ]
}
worker_instance_ips = {
  "external_ip_address" = [
    "51.250.43.139",
    "51.250.35.160",
    "51.250.39.74",
    "51.250.47.234",
  ]
  "internal_ip_address" = [
    "192.168.100.19",
    "192.168.100.24",
    "192.168.100.22",
    "192.168.100.17",
  ]
  "name" = [
    "worker-0",
    "worker-1",
    "worker-2",
    "worker-3",
  ]
}
```
Вносим изменения в файл инвентори `ya.yml`
```yaml
---
master:
  hosts:
    master-01:
      ansible_host: 51.250.42.158
      ansible_user: ubuntu

worker:
  hosts:
    worker-01:
      ansible_host: 51.250.43.139
      ansible_user: ubuntu
    worker-02:
      ansible_host: 51.250.35.160
      ansible_user: ubuntu
    worker-03:
      ansible_host: 51.250.39.74
      ansible_user: ubuntu
    worker-04:
      ansible_host: 51.250.47.234
      ansible_user: ubuntu
```
Далее запускаем `ansible playbook`:
```bash
antigen@deb11notepad:~/netology/12/terraform$ cd ../ansible/
antigen@deb11notepad:~/netology/12/ansible$ ansible-playbook -i inventory/ya.yml k8s.yml

PLAY [master] ************************************************************************************************************************************************************************

TASK [Gathering Facts] ***************************************************************************************************************************************************************
ok: [master-01]

TASK [Init Cluaster] *****************************************************************************************************************************************************************
changed: [master-01]

TASK [mkdir .kube] *******************************************************************************************************************************************************************
changed: [master-01]

TASK [Copy admin.conf] ***************************************************************************************************************************************************************
changed: [master-01]

TASK [Get Join Command] **************************************************************************************************************************************************************
changed: [master-01]

TASK [Set Join Command] **************************************************************************************************************************************************************
ok: [master-01]

PLAY [worker] ************************************************************************************************************************************************************************

TASK [Gathering Facts] ***************************************************************************************************************************************************************
ok: [worker-02]
ok: [worker-03]
ok: [worker-01]
ok: [worker-04]

TASK [Join Cluster] ******************************************************************************************************************************************************************
changed: [worker-01]
changed: [worker-03]
changed: [worker-02]
changed: [worker-04]

PLAY RECAP ***************************************************************************************************************************************************************************
master-01                  : ok=6    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
worker-01                  : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
worker-02                  : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
worker-03                  : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
worker-04                  : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
После раскатки плэйбука заходим на мастер и смотрим что получилось:
```bash
antigen@deb11notepad:~/netology/12/ansible$ ssh ubuntu@51.250.42.158
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.4.0-149-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage
New release '22.04.2 LTS' available.
Run 'do-release-upgrade' to upgrade to it.

Last login: Sun Jun  4 11:50:09 2023 from xx.yy.zz.ii
ubuntu@ef3jvmga4fov8rlbm2av:~$ kubectl get nodes
NAME                   STATUS     ROLES           AGE     VERSION
ef320av1v1gi6f6gfo48   NotReady   <none>          4m48s   v1.27.2
ef3dnukdg6brpvf91eh5   NotReady   <none>          4m45s   v1.27.2
ef3jvmga4fov8rlbm2av   NotReady   control-plane   5m10s   v1.27.2
ef3leq5cg1bh9miog3ad   NotReady   <none>          4m48s   v1.27.2
ef3sadvins7h9lujni9s   NotReady   <none>          4m48s   v1.27.2
```

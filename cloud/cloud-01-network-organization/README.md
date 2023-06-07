# Домашнее задание к занятию «Организация сети»

### Подготовка к выполнению задания

1. Домашнее задание состоит из обязательной части, которую нужно выполнить на провайдере Yandex Cloud, и дополнительной части в AWS (выполняется по желанию). 
2. Все домашние задания в блоке 15 связаны друг с другом и в конце представляют пример законченной инфраструктуры.  
3. Все задания нужно выполнить с помощью Terraform. Результатом выполненного домашнего задания будет код в репозитории. 
4. Перед началом работы настройте доступ к облачным ресурсам из Terraform, используя материалы прошлых лекций и домашнее задание по теме «Облачные провайдеры и синтаксис Terraform». Заранее выберите регион (в случае AWS) и зону.

---
### Задание 1. Yandex Cloud 

> **Что нужно сделать**
> 
> 1. Создать пустую VPC. Выбрать зону.
> 2. Публичная подсеть.
> 
>  - Создать в VPC subnet с названием public, сетью 192.168.10.0/24.
>  - Создать в этой подсети NAT-инстанс, присвоив ему адрес 192.168.10.254. В качестве image_id использовать fd80mrhj8fl2oe87o4e1.
>  - Создать в этой публичной подсети виртуалку с публичным IP, подключиться к ней и убедиться, что есть доступ к интернету.
> 3. Приватная подсеть.
>  - Создать в VPC subnet с названием private, сетью 192.168.20.0/24.
>  - Создать route table. Добавить статический маршрут, направляющий весь исходящий трафик private сети в NAT-инстанс.
>  - Создать в этой приватной подсети виртуалку с внутренним IP, подключиться к ней через виртуалку, созданную ранее, и убедиться, что есть доступ к интернету.
> 
> Resource Terraform для Yandex Cloud:
> 
> - [VPC subnet](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_subnet).
> - [Route table](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_route_table).
> - [Compute Instance](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_instance).

Листинг `yc.tf`:
```terraform
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone = var.yc_zone
}
```
Листинг `vars.tf`:
```terraform
# Token
variable "yc_token" {
  type = string
}

# Переменная окружения TF_VAR_yc_cloud_id
variable "yc_cloud_id" {
  type = string
}

# Переменная окружения TF_VAR_yc_folder_id
variable "yc_folder_id" {
  type = string
}

# Переменная окружения TF_VAR_yc_zone
variable "yc_zone" {
  type = string
}
```
Листинг `outputs.tf`:
```terraform
output "private_instance_ips" {
  value = {
    external_ip_address = yandex_compute_instance.private_vm[*].network_interface.0.nat_ip_address
    internal_ip_address = yandex_compute_instance.private_vm[*].network_interface.0.ip_address
    name = yandex_compute_instance.private_vm[*].name
  }
}

output "public_instance_ips" {
  value = {
    external_ip_address = yandex_compute_instance.public_vm[*].network_interface.0.nat_ip_address
    internal_ip_address = yandex_compute_instance.public_vm[*].network_interface.0.ip_address
    name = yandex_compute_instance.public_vm[*].name
  }
}
```
Листинг `network.tf`:
```terraform
resource "yandex_vpc_network" "network" {
  name = "mynetwork"
}

resource "yandex_vpc_subnet" "public" {
  name = "public"
  v4_cidr_blocks = ["192.168.10.0/24"]
  network_id = yandex_vpc_network.network.id
}

resource "yandex_vpc_subnet" "private" {
  name = "private"
  v4_cidr_blocks = ["192.168.20.0/24"]
  network_id = yandex_vpc_network.network.id
  route_table_id = yandex_vpc_route_table.route-01.id
}

resource "yandex_vpc_route_table" "route-01" {
  name = "route-01"
  network_id = yandex_vpc_network.network.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address = yandex_compute_instance.public_vm.network_interface.0.ip_address
  }
}
```
Листинг `instance.tf`:
```terraform
data "yandex_compute_image" "ubuntu" {
  image_id = "fd8o8aph4t4pdisf1fio"
}

resource "yandex_compute_instance" "public_vm" {
  name = "public-vm"
  hostname = "public-vm"

  resources {
    cores = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}

resource "yandex_compute_instance" "private_vm" {
  name      = "private-vm"
  hostname    = "private-vm"

  resources {
    cores = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
    nat = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}
```
Листинг `.env`:
```bash
export TF_VAR_yc_token=AQAAxxxxxxxxxxxxxxxxxxxxt9I
export TF_VAR_yc_cloud_id=b1gxxxxxxxxxxxr3d
export TF_VAR_yc_folder_id=b1gxxxxxxxxxxfucc
export TF_VAR_yc_zone=ru-central1-c
```
Применяем `.env`:
```bash
antigen@deb11notepad:~/netology/16$ source .env
```
Инициализируем `terraform`, проверяем и запускаем:
```bash
antigen@deb11notepad:~/netology/16$ terraform init
...
antigen@deb11notepad:~/netology/16$ terraform validate
Success! The configuration is valid.
antigen@deb11notepad:~/netology/16$ terraform apply --auto-approve
...
Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

private_instance_ips = {
  "external_ip_address" = [
    "",
  ]
  "internal_ip_address" = [
    "192.168.20.20",
  ]
  "name" = [
    "private-vm",
  ]
}
public_instance_ips = {
  "external_ip_address" = [
    "51.250.39.226",
  ]
  "internal_ip_address" = [
    "192.168.10.16",
  ]
  "name" = [
    "public-vm",
  ]
}
```
Проверяем, что получилось:
```bash
antigen@deb11notepad:~/netology/16$ yc compute instance list
+----------------------+------------+---------------+---------+---------------+---------------+
|          ID          |    NAME    |    ZONE ID    | STATUS  |  EXTERNAL IP  |  INTERNAL IP  |
+----------------------+------------+---------------+---------+---------------+---------------+
| ef3hb8gte1iccvis0np6 | public-vm  | ru-central1-c | RUNNING | 51.250.39.226 | 192.168.10.16 |
| ef3om4k34utdfaamctrg | private-vm | ru-central1-c | RUNNING |               | 192.168.20.20 |
+----------------------+------------+---------------+---------+---------------+---------------+

antigen@deb11notepad:~/netology/16$ yc vpc network list
+----------------------+-----------+
|          ID          |   NAME    |
+----------------------+-----------+
| enpi3ev6hse6jm1hkul1 | mynetwork |
+----------------------+-----------+

antigen@deb11notepad:~/netology/16$ yc vpc subnet list
+----------------------+---------+----------------------+----------------------+---------------+-------------------+
|          ID          |  NAME   |      NETWORK ID      |    ROUTE TABLE ID    |     ZONE      |       RANGE       |
+----------------------+---------+----------------------+----------------------+---------------+-------------------+
| b0chfsj4ltacjp91t3ho | public  | enpi3ev6hse6jm1hkul1 |                      | ru-central1-c | [192.168.10.0/24] |
| b0cp163mb6r7uonpupqj | private | enpi3ev6hse6jm1hkul1 | enpho1efg68bahmmvnje | ru-central1-c | [192.168.20.0/24] |
+----------------------+---------+----------------------+----------------------+---------------+-------------------+

antigen@deb11notepad:~/netology/16$ yc vpc route-table list
+----------------------+----------+-------------+----------------------+
|          ID          |   NAME   | DESCRIPTION |      NETWORK-ID      |
+----------------------+----------+-------------+----------------------+
| enpho1efg68bahmmvnje | route-01 |             | enpi3ev6hse6jm1hkul1 |
+----------------------+----------+-------------+----------------------+

antigen@deb11notepad:~/netology/16$ yc vpc route-table get enpho1efg68bahmmvnje

id: enpho1efg68bahmmvnje
folder_id: b1gebf7j46aqpmhmfucc
created_at: "2023-06-07T20:10:46Z"
name: route-01
network_id: enpi3ev6hse6jm1hkul1
static_routes:
  - destination_prefix: 0.0.0.0/0
    next_hop_address: 192.168.10.16
```
Скидываем ключи в `public-vm` и подключаемся:
```bash
antigen@deb11notepad:~/netology/16$ scp /home/antigen/.ssh/id_ed25519* ubuntu@51.250.39.226:~/.ssh/
id_ed25519                                                                                                                                          100%  411    13.8KB/s   00:00
id_ed25519.pub                                                                                                                                      100%  102     3.2KB/s   00:00
antigen@deb11notepad:~/netology/16$ ssh ubuntu@51.250.39.226
Welcome to Ubuntu 18.04.6 LTS (GNU/Linux 4.15.0-112-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage
New release '20.04.6 LTS' available.
Run 'do-release-upgrade' to upgrade to it.



#################################################################
This instance runs Yandex.Cloud Marketplace product
Please wait while we configure your product...

Documentation for Yandex Cloud Marketplace images available at https://cloud.yandex.ru/docs

#################################################################

Last login: Wed Jun  7 20:14:02 2023 from 88.87.84.72
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

ubuntu@public-vm:~$ 
```
Теперь цепляемся к `private-vm` и пингуем яндекс:
```bash
ubuntu@public-vm:~$ ssh ubuntu@192.168.20.20
Welcome to Ubuntu 18.04.6 LTS (GNU/Linux 4.15.0-112-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage


#################################################################
This instance runs Yandex.Cloud Marketplace product
Please wait while we configure your product...

Documentation for Yandex Cloud Marketplace images available at https://cloud.yandex.ru/docs

#################################################################


The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

ubuntu@private-vm:~$ ping ya.ru
PING ya.ru (77.88.55.242) 56(84) bytes of data.
64 bytes from ya.ru (77.88.55.242): icmp_seq=1 ttl=249 time=8.62 ms
64 bytes from ya.ru (77.88.55.242): icmp_seq=2 ttl=249 time=7.76 ms
64 bytes from ya.ru (77.88.55.242): icmp_seq=3 ttl=249 time=7.64 ms
64 bytes from ya.ru (77.88.55.242): icmp_seq=4 ttl=249 time=7.73 ms
^C
--- ya.ru ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3005ms
rtt min/avg/max/mdev = 7.642/7.941/8.620/0.394 ms
ubuntu@private-vm:~$ ^C
```

---
### Задание 2. AWS* (задание со звёздочкой)

Это необязательное задание. Его выполнение не влияет на получение зачёта по домашней работе.

**Что нужно сделать**

1. Создать пустую VPC с подсетью 10.10.0.0/16.
2. Публичная подсеть.

 - Создать в VPC subnet с названием public, сетью 10.10.1.0/24.
 - Разрешить в этой subnet присвоение public IP по-умолчанию.
 - Создать Internet gateway.
 - Добавить в таблицу маршрутизации маршрут, направляющий весь исходящий трафик в Internet gateway.
 - Создать security group с разрешающими правилами на SSH и ICMP. Привязать эту security group на все, создаваемые в этом ДЗ, виртуалки.
 - Создать в этой подсети виртуалку и убедиться, что инстанс имеет публичный IP. Подключиться к ней, убедиться, что есть доступ к интернету.
 - Добавить NAT gateway в public subnet.
3. Приватная подсеть.
 - Создать в VPC subnet с названием private, сетью 10.10.2.0/24.
 - Создать отдельную таблицу маршрутизации и привязать её к private подсети.
 - Добавить Route, направляющий весь исходящий трафик private сети в NAT.
 - Создать виртуалку в приватной сети.
 - Подключиться к ней по SSH по приватному IP через виртуалку, созданную ранее в публичной подсети, и убедиться, что с виртуалки есть выход в интернет.

Resource Terraform:

1. [VPC](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc).
1. [Subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet).
1. [Internet Gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway).


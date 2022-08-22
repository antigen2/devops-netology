# Provider
provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_zone
}

# Образ
data "yandex_compute_image" "my_ubuntu_2004" {
  family        = "ubuntu-2004-lts"
#  source_image  = "fd8kdq6d0p8sij7h5qe3"
}

# Сеть
resource "yandex_vpc_network" "my_net" {
  name = "my_net"
}

# Подсеть
resource "yandex_vpc_subnet" "my_subnet" {
  name            = "my_subnet"
  zone            = var.yc_zone
  network_id      = yandex_vpc_network.my_net.id
  v4_cidr_blocks  = ["172.16.10.0/24"]
}

## Виртуалка
#resource "yandex_compute_instance" "vm_my-test" {
#
#  name = "${terraform.workspace}_vm-${count.index}"
#
#  # Ресурсы для виртуалки
#  resources {
#    cores  = 2
#    memory = 4
#  }
#
#  # Образ загрузки
#  boot_disk {
#    initialize_params {
#      image_id = data.yandex_compute_image.my_ubuntu_2004.id
#      type = "network-nvme"
#      size = 20
#    }
#  }
#
#  # Сетевой интерфейс
#  network_interface {
#    subnet_id = yandex_vpc_subnet.my_subnet.id
#    nat       = true
#  }
#
#  count = local.my_vm_instance_count[terraform.workspace]
#
#  # Метаданные пользователя
#  metadata = {
#    ssh-key = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
#  }
#}

resource "yandex_compute_instance" "vm_enum" {

  for_each = local.id
  name = "${terraform.workspace}_vm-${each.key}"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.my_ubuntu_2004.id
      type = "network-nvme"
      size = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.my_subnet.id
    nat       = true
  }

  metadata = {
    ssh-key = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

}

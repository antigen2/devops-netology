
# Provider
provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone = var.yc_zone
}

# Образ
data "yandex_compute_image" "vm_ubuntu_2004" {
  family = "ubuntu-2004-lts"
}

# Сеть
resource "yandex_vpc_network" "k8s-network" {
  name = "k8s-network"
}

# Подсеть
resource "yandex_vpc_subnet" "k8s-subnet-1" {
  name = "k8s-subnet-1"
  zone = var.yc_zone
  network_id     = yandex_vpc_network.k8s-network.id
  v4_cidr_blocks = ["172.16.3.0/24"]
  depends_on = [
    yandex_vpc_network.k8s-network,
  ]
}

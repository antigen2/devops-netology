variable "yc_token" { type = string }
variable "yc_cloud_id" { type = string }
variable "yc_folder_id" { type = string }
variable "yc_zone" { type = string }

terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.80"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_zone
}

resource "yandex_vpc_network" "default" {
  name = "net"
}

resource "yandex_vpc_subnet" "default" {
  name           = "subnet"
  v4_cidr_blocks = ["172.16.10.0/24"]
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.default.id
}

resource "yandex_compute_image" "os-centos" {
  name          = "os-centos-stream"
  source_family = "centos-stream-8"
}

module "jen-master" {
  source = "./vm"

  name        = "jenkins-master-01"
  user        = "centos"
  description = "Jenkins Master"
  cpu         = 2
  ram         = 2
  cpu_load    = 5
  main_disk_image = yandex_compute_image.os-centos.id
  main_disk_size  = 10
  subnet      = yandex_vpc_subnet.default.id
}

module "jen-slave" {
  source = "./vm"

  count       = 1

  name        = "jenkins-agent-${format("%02d", count.index + 1)}"
  user        = "centos"
  description = "Jenkins Slave Node ${count.index + 1}"
  cpu         = 2
  ram         = 4
  cpu_load    = 20
  main_disk_image = yandex_compute_image.os-centos.id
  main_disk_size  = 10
  subnet      = yandex_vpc_subnet.default.id
}

output "master_ip" {
  value = module.jen-master.external_ip
}

output "slave_ip" {
  value = module.jen-slave[*].external_ip
}
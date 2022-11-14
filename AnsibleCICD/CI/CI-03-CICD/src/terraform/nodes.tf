resource "yandex_compute_instance" "nodes" {

  for_each = local.names
  name                      = each.key
  zone                      = var.yc_zone
  hostname                  = "${each.key}.netology"

  resources {
    cores  = var.instance_cores
    memory = var.instance_memory
  }

  boot_disk {
    initialize_params {
      image_id    = var.centos-7
      type        = "network-nvme"
      size        = "20"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.default.id
    nat       = true
  }

  metadata = {
    ssh-keys = "centos:${file("~/.ssh/id_rsa.pub")}"
  }

}

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

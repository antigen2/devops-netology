output "worker_instance_ips" {
  value = {
    external_ip_address = yandex_compute_instance.worker_instance[*].network_interface.0.nat_ip_address
    internal_ip_address = yandex_compute_instance.worker_instance[*].network_interface.0.ip_address
    name = yandex_compute_instance.worker_instance[*].name
  }
}

output "master_instance_ips" {
  value = {
    external_ip_address = yandex_compute_instance.master_instance[*].network_interface.0.nat_ip_address
    internal_ip_address = yandex_compute_instance.master_instance[*].network_interface.0.ip_address
    name = yandex_compute_instance.master_instance[*].name
  }
}
output "internal_ip_address_vm_test" {
  value = yandex_compute_instance.vm_test.network_interface.0.ip_address
}

output "external_ip_address_vm_test" {
  value = yandex_compute_instance.vm_test.network_interface.0.nat_ip_address
}

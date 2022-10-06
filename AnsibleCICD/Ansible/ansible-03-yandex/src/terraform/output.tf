output "internal_ip_address_nodes" {
  value = {for i in local.names: i => yandex_compute_instance.nodes[i].network_interface.0.ip_address}
}

output "external_ip_address_nodes" {
  value = {for i in local.names: i => yandex_compute_instance.nodes[i].network_interface.0.nat_ip_address}
}

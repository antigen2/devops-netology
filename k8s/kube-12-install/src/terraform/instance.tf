# Виртуалка worker
resource "yandex_compute_instance" "worker_instance" {

  count = var.worker_instance_count

  name = "worker-${count.index}"

  # Ресурсы для виртуалки
  resources {
    cores = 2
    memory = 2
  }
  # Образ загрузки
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.vm_ubuntu_2004.id
      type = "network-nvme"
      size = 20
    }
  }
  # Сетевой интерфейс
  network_interface {
    subnet_id = yandex_vpc_subnet.k8s-subnet-1.id
    nat = true
  }
  # Метаданные пользователя
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }

#  provisioner "remote-exec" {
#      inline = [
#        "sudo apt-get update",
#        "sudo apt-get install -y apt-transport-https ca-certificates curl",
#        "sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://dl.k8s.io/apt/doc/apt-key.gpg",
#        "echo \"deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main\" | sudo tee /etc/apt/sources.list.d/kubernetes.list",
#        "sudo apt-get update",
#        "sudo apt-get install -y kubelet kubeadm kubectl containerd",
#        "sudo apt-mark hold kubelet kubeadm kubectl"
#      ]
#    }

  provisioner "remote-exec" {
      inline = [
        "sudo apt-get update",
        "sudo apt-get install -y apt-transport-https ca-certificates curl",
        "sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://dl.k8s.io/apt/doc/apt-key.gpg",
        "echo \"deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main\" | sudo tee /etc/apt/sources.list.d/kubernetes.list",
        "sudo apt-get update",
        "sudo apt-get install -y kubelet kubeadm kubectl containerd",
        "sudo apt-mark hold kubelet kubeadm",
        "sudo modprobe br_netfilter",
        "echo \"net.ipv4.ip_forward=1\" | sudo tee -a /etc/sysctl.conf",
        "echo \"net.bridge.bridge-nf-call-iptables=1\" | sudo tee -a /etc/sysctl.conf",
        "echo \"net.bridge.bridge-nf-call-arptables=1\" | sudo tee -a /etc/sysctl.conf",
        "echo \"net.bridge.bridge-nf-call-ip6tables=1\" | sudo tee -a /etc/sysctl.conf",
        "sudo sysctl -p /etc/sysctl.conf"
      ]
  }

  connection {
    host        = self.network_interface.0.nat_ip_address
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file(var.ssh_key_private)}"
  }
}

# Виртуалка master
resource "yandex_compute_instance" "master_instance" {

  count = var.master_instance_count

  name = "master-${count.index}"

  # Ресурсы для виртуалки
  resources {
    cores = 2
    memory = 2
  }
  # Образ загрузки
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.vm_ubuntu_2004.id
      type = "network-nvme"
      size = 20
    }
  }
  # Сетевой интерфейс
  network_interface {
    subnet_id = yandex_vpc_subnet.k8s-subnet-1.id
    nat = true
  }
  # Метаданные пользователя
  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_key_pub)}"
  }

  provisioner "remote-exec" {
      inline = [
        "sudo apt-get update",
        "sudo apt-get install -y apt-transport-https ca-certificates curl",
        "sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://dl.k8s.io/apt/doc/apt-key.gpg",
        "echo \"deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main\" | sudo tee /etc/apt/sources.list.d/kubernetes.list",
        "sudo apt-get update",
        "sudo apt-get install -y kubelet kubeadm kubectl containerd",
        "sudo apt-mark hold kubelet kubeadm kubectl",
        "sudo modprobe br_netfilter",
        "echo \"net.ipv4.ip_forward=1\" | sudo tee -a /etc/sysctl.conf",
        "echo \"net.bridge.bridge-nf-call-iptables=1\" | sudo tee -a /etc/sysctl.conf",
        "echo \"net.bridge.bridge-nf-call-arptables=1\" | sudo tee -a /etc/sysctl.conf",
        "echo \"net.bridge.bridge-nf-call-ip6tables=1\" | sudo tee -a /etc/sysctl.conf",
        "sudo sysctl -p /etc/sysctl.conf"
      ]
  }

  connection {
    host        = self.network_interface.0.nat_ip_address
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file(var.ssh_key_private)}"
#    agent = true
#    timeout = "3m"
  }
}

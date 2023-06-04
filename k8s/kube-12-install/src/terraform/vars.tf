# Переменная окружения TF_VAR_yc_token
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

# Количество worker инстансов
variable "worker_instance_count" {
  default = "4"
}

# Количество master инстансов
variable "master_instance_count" {
  default = "1"
}

variable "ssh_key_private" {
  default = "~/.ssh/id_ed25519"
}

variable "ssh_key_pub" {
  default = "~/.ssh/id_ed25519.pub"
}
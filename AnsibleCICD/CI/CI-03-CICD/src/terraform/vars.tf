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

# Образ с яндекс.клауда:  yc compute image list --folder-id standard-images | grep centos-7-v202211
variable "centos-7" {
  default = "fd89dg08jjghmn88ut7p"
}

# Количество ядер
variable "instance_cores" {
  default = "2"
}

# Количество оперативы
variable "instance_memory" {
  default = "4"
}

# Перечисление виртуалок
locals {
    names = toset (
        ["sonar-01", "nexus-01"]
    )
}

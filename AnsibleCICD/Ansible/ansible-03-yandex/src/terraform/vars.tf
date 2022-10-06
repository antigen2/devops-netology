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

# Образ с яндекс.клауда:  yc compute image list --folder-id standard-images | grep centos-8-v2022
variable "centos-8" {
  default = "fd86tafe9jg6c4hd2aqp"
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
        ["clickhouse-01", "vector-01", "lighthouse-01"]
    )
}

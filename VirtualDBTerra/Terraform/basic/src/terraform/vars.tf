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

locals {
  news_cores = {
    default = 2
    stage = 2
    prod = 2
  }
  news_disk_size = {
    default = 20
    stage = 20
    prod = 40
  }
  news_instance_count = {
    default = 1
    stage = 1
    prod = 2
  }
  vpc_subnet = {
    default = [
      {
        zone            = var.yc_zone
        v4_cidr_blocks  = ["10.10.1.0/24"]
      }
    ]
    stage = [
      {
        zone            = var.yc_zone
        v4_cidr_blocks  = ["10.10.1.0/24"]
      }
    ]
    prod = [
      {
         zone            = "ru-central1-a"
        v4_cidr_blocks  = ["10.10.1.0/24"]
      },
      {
        zone            = "ru-central1-b"
        v4_cidr_blocks  = ["10.10.2.0/24"]
      },
      {
        zone            = "ru-central1-c"
        v4_cidr_blocks  = ["10.10.3.0/24"]
      }
    ]
  }
}
# Ход работ
#### Инициализация (yc):
- `yc init`
#### Смотрим конфигурацию:
- `yc config list`
#### Создаем сеть и подсеть, если это необходимо:
- `yc vpc network create --name net`
- `yc vpc subnet create --name my-subnet-c --zone ru-central1-c --range 10.1.2.0/24 --network-name net`
#### Создаем сервис-ключ, если необходимо:
- `yc iam key create --service-account-name antigen2-sa --output key.json`
#### Инициализация (terraform):
- `terraform init`
#### Проверяем конфиг (план) (terraform):
- `terraform plan`
#### Применяем план (terraform): 
- `terraform apply --auto-approve`
#### Проверяем конфиг (ansible):
- `ansible-lint src/ansible/site.yml`
#### Удаление виртуалок (terraform):
- `terraform destroy --auto-approve`

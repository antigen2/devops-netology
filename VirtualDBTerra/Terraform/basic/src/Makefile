# WORKSPACE=stage make all
# WORKSPACE=prod make all

WORKSPACE?=default

all: init workspace plan apply #pause deploy
all_1: init plan apply

#cd_terra:
#	cd ./terraform

init:
	cd ./terraform && terraform init

workspace:
	cd ./terraform && terraform workspace new ${WORKSPACE}

set_workspace:
	cd ./terraform && terraform workspace select ${WORKSPACE}

plan: set_workspace
	cd ./terraform && terraform plan

apply: set_workspace
	cd ./terraform && terraform apply -auto-approve

destroy: set_workspace
	cd ./terraform && terraform destroy -auto-approve

clean:
	cd ./terraform &&  rm -f terraform.tfplan
	cd ./terraform &&  rm -f .terraform.lock.hcl
	cd ./terraform &&  rm -fr terraform.tfstate*
	cd ./terraform &&  rm -fr .terraform/

#pause:
#	echo "Wait for 30 seconds stupid Yandex Cloud creating a VM's..."
#	sleep 30
#
#deploy:
#	cd ./ansible && source .env.news-app && ansible-playbook -i inventory/demo site.yml
#
#reconfig:
#	cd ./ansible && source .env.news-app && ansible-playbook -i inventory/demo site.yml -t config

# WORKSPACE=stage make all

WORKSPACE?=default

all: init workspace plan apply #pause deploy

cd_terra:
	cd ./terraform

init:
	cd_terra && terraform init

workspace:
	cd_terra && terraform workspace new ${WORKSPACE}

set_workspace:
	cd_terra && terraform workspace select ${WORKSPACE}

plan: set_workspace
	cd_terra && terraform plan

apply: set_workspace
	cd_terra && terraform apply -auto-approve

destroy: set_workspace
	cd_terra && terraform destroy -auto-approve

clean:
	cd_terra &&  rm -f terraform.tfplan
	cd_terra &&  rm -f .terraform.lock.hcl
	cd_terra &&  rm -fr terraform.tfstate*
	cd_terra &&  rm -fr .terraform/

#pause:
#	echo "Wait for 30 seconds stupid Yandex Cloud creating a VM's..."
#	sleep 30
#
#deploy:
#	cd ./ansible && source .env.news-app && ansible-playbook -i inventory/demo site.yml
#
#reconfig:
#	cd ./ansible && source .env.news-app && ansible-playbook -i inventory/demo site.yml -t config

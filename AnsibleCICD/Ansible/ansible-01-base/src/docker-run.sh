#!/usr/bin/env bash

# correct parameters:
# run - run docker containers
# stop - stop & delete containers

DIR=$(pwd)
DIRp=${DIR}/playbook
DIRi=${DIRp}/inventory

run() {
  ansible-playbook -i ${DIRi}/test.yml ${DIR}/docker_with_fedora.yml
  ansible-playbook -i ${DIRi}/prod.yml ${DIR}/install_py3_with_fedora.yml
  ansible-playbook -i ${DIRi}/prod.yml ${DIRp}/site.yml
}

stop() {

}

list_commands() {

}

if [[ $# != 1 ]]; then
  echo "invalid parameters"
  list_commands
  exit 1
fi

if [[ $1 == 'run' ]]; then
  run
  exit 0
fi

if [[ $1 == 'run' ]]; then
  stop
  exit 0
fi



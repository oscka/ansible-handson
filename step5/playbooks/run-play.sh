#!/bin/bash

TAGS=$1

# export ANSIBLE_HOST_KEY_CHECKING=False

# ansible-playbook -i hosts-aws  playbook-run-all.yml   -t "$TAGS" 
# os별로 혹은 환경별로 external-vars 를 만들어 실행할 수 있음
ansible-playbook -i hosts-azure  playbook-run-all.yml -t "$TAGS" -e "@external-vars.yml"


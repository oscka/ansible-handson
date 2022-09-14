#!/bin/bash

TAGS=$1

# export ANSIBLE_HOST_KEY_CHECKING=False

# ansible-playbook -i hosts-aws  playbook-run-all.yml   -t "$TAGS" 
ansible-playbook -i hosts-aws  playbook-run-all.yml   -t "$TAGS" -e "@external-vars.yml"


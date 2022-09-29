#!/bin/bash

TAGS=$1

export ANSIBLE_HOST_KEY_CHECKING=False

ansible-playbook -i hosts-vm  playbook-step4.yml   -t "$TAGS" 
# ansible-playbook -i hosts-vm  playbook-step4.yml   -t "$TAGS" -e "@external-vm-vars.yml"
# with azure
# ansible-playbook -i hosts-azure  playbook-step4.yml   -t "$TAGS" 


#!/bin/bash

TAGS=$1

export ANSIBLE_HOST_KEY_CHECKING=False

if [ -z $TAGS ]; then
    ansible-playbook  playbook-step4.yml   --list-tags --list-tasks
else
    ansible-playbook  playbook-step4.yml  --list-tasks | grep $TAGS
fi

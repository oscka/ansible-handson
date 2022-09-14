#!/bin/bash

TAGS=$1

if [ -z $TAGS ]; then
    ansible-playbook  playbook-run-all.yml   --list-tags --list-tasks
else
    ansible-playbook  playbook-run-all.yml  --list-tasks | grep $TAGS
fi

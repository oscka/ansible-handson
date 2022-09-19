#!/bin/bash

TAGS=$1



# k8s-user
#
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i hosts-k8s playbook-k8s-cluster.yml   -t "$TAGS" 

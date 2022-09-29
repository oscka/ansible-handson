#!/bin/bash

export ANSIBLE_HOST_KEY_CHECKING=False

ansible -i hosts-k8s all -m ping

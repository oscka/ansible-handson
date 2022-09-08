#!/bin/bash

export ANSIBLE_HOST_KEY_CHECKING=False

ansible -i hosts-vm all -m ping

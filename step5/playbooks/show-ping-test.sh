#!/bin/bash

# export ANSIBLE_HOST_KEY_CHECKING=False

ansible -i hosts-aws all -m ping

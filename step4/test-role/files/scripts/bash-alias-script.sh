#!/bin/bash

echo "alias k='kubectl'" >> ~/.bash_profile
echo "alias kg='kubectl get $1'" >> ~/.bash_profile

echo "alias ktail='kubetail'" >> ~/.bash_profile
echo "alias sff='skaffold'" >> ~/.bash_profile

echo "alias wall='watch kubectl get all -n $1'" >> ~/.bash_profile
echo "alias wpod='watch kubectl get pod -n $1'" >> ~/.bash_profile
echo "alias wpodA='watch kubectl get pod -A'" >> ~/.bash_profile
echo "alias kctx='kubectx'" >> ~/.bash_profile
echo "alias kns='kubens'" >> ~/.bash_profile

echo "alias dk='docker'" >> ~/.bash_profile
echo "alias dkc='docker-compose'" >> ~/.bash_profile
echo "alias kcat='kafkacat'" >> ~/.bash_profile
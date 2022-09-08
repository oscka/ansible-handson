# ansible-handson project

솔루션 설치 자동화를 위한 ansible handson

```bash
# ping
ansible -i hosts-vm all -m ping
# host 목록 조회
ansible -i hosts-vm all --list-hosts

# step1
# playbook 실행
ansible-playbook -i hosts-vm playbook-step1.yml
# step2
# 해당 tag 만 실행
ansible-playbook -i hosts-vm playbook-step1.yml -t "pre, docker, k9s"
# step3
# role 생성
ansible-galaxy init test-role 
# tag list 조회
ansible-playbook -i hosts-vm playbook-step3.yml --list-tag 
# task list 조회
ansible-playbook -i hosts-vm playbook-step3.yml --list-tasks
ansible-playbook -i hosts-vm playbook-step3.yml -t "kubectl"
```

실행을 위해서 각 step의 hosts-vm 파일의 IP 및 경로를 맞게 수정해야 함
```
ansible_host=192.168.56.10 ansible_user=vagrant ansible_port=22 ansible_ssh_private_key_file=/home/ska/git/study/ansible/test-vm1/.vagrant/machines/default/virtualbox/private_key
# ansible_host=192.168.56.10 -> private_ip를 맞게 수정
# ansible_ssh_private_key_file=/home/ska/git/study/ansible/test-vm1/ # --> vagrant ssh-config로 확인하여 경로에 맞게 수정
```
기본적으로 vagrant를 기반으로 수행할 수 있도록 구성(vagrant 계정으로 실행되어 sudo권한이 기본적으로 부여되어 있음)


vm초기화 후 다시 시작할 경우 known_host파일을 삭제하고 다시 해당 vm을 등록해야 한다
```
rm /home/{자신의ID}/.ssh/known_hosts
ansible -i hosts-vm all -m ping
# 한뒤 yes로 vm 갯수만큼 다시 known_host에 등록
```

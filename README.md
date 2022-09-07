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

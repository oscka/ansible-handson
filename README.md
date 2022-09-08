# ansible project

for ansible test

```bash
# 다시 ping
ansible -i hosts-vm all -m ping
# host 목록 조회
ansible -i hosts-vm all --list-hosts
# playbook 실행
ansible-playbook -i hosts-vm playbook-step1.yml
# 해당 tag 만 실행
ansible-playbook -i hosts-vm playbook-step1.yml -t "pre, docker, k9s"

# role 생성
ansible-galaxy init test-role 
# tag list 조회
ansible-playbook -i hosts-vm playbook-step3.yml --list-tag 
# task list 조회
ansible-playbook -i hosts-vm playbook-step3.yml --list-tasks



ansible-playbook -i hosts-vm playbook-step3.yml -t "kubectl"
```

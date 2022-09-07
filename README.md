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

실행을 위해서 각 step의 hosts-vm 파일의 다음 경로를 맞게 수정해야 함
```
ansible_ssh_private_key_file=/home/ska/git/study/ansible/test-vm1/ # --> vagrant ssh-config로 확인하여 경로에 맞게 수정
```

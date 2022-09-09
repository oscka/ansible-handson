# ansible-handson project

이 프로젝트는 솔루션 설치 자동화를 위해 vagrant로 vm을 만들어 설치 대상서버로 사용하며, ansible로 대상에 솔루션 및 오픈소스를 설치하여 테스트합니다.

핸즈온을 위해 미리 설치가 필요한 것들은 다음과 같습니다.

## 사전설치

핸즈온 실행을 위해 vagrant와 ansible은 사전 설치가 필요합니다. 
ansible 버전은 가급적 맞추는 것이 좋습니다. 버전이 다를 경우 실행 자체가 되지 않는 경우가 있습니다.
(글 작성 시점-2022.09.10-기준)

- Vagrant(version 2.3.0) - https://www.vagrantup.com/downloads
- Ansible(version 2.13.4) -  
  - 참고:(ubuntu에서 최신버전 설치하기)[https://www.cyberciti.biz/faq/how-to-install-and-configure-latest-version-of-ansible-on-ubuntu-linux/]

## 구성요소

- Vagrant - mac, window, linux OS플랫폼 별로 존재하나 vagrant로 구동될 OS는 ubuntu/focal64 공식 이미지를 사용합니다. 2개 vm을 실행하여 
- ansible - 플랫폼을 가리지 않으나 가급적 mac혹은 linux를 사용하는 것을 권장합니다.

핸즈온을 위해 바깥의 OS -> 2개의 vm으로 ssh로 연결하여 ansible이 실행되며 이를 위해 vagrant의 ssh정보를 이용합니다. 

ssh key조회를 위해서 vagrant ssh-config 를 통해 확인한 뒤 각 step의 hosts-vm안에 경로에 해당 key파일의 경로를 넣어야 ansible이 이를 통해 설치를 수행할 수 있습니다.

## 핸즈온 Steps

### step0(준비)

처음 vm을 실행하고 ansible ping을 성공하기 위해 ssh로 대상을 신뢰하는 host로 등록이 되어 있어야 합니다.

ping실행시 yes/no를 물어보는 부분이 나올 경우 yes로 등록하고 메세지가 나오지 않을때까지 몇번 수행해 봅니다.

vm 재생성시에는 각 vm들을 vagrant destroy -f 로 삭제한 뒤 .ssh하위의 known_host 파일도 삭제해야 합니다.

ping을 통해 등록된 host들에서 pong이 올 경우 준비가 완료된 것입니다.

```bash
# 다시 ping(맨 처음 실행시 yes로 등록필요)
ansible -i hosts-vm all -m ping
# host 목록 조회
ansible -i hosts-vm all --list-hosts
# known_hosts 초기화
rm ~/.ssh/known_hosts
```

### Step1

```bash
# playbook 실행
ansible-playbook -i hosts-vm playbook-step1.yml
```

### Step2

각 ansible task들은 tag를 지정할 수 있으며 차후 설치 편의를 위해 task마다 적당한 이름을 붙여 넣습니다.

tag는 여러개를 한번에 넣어 순차적으로 실행되도록 할 수도 있고, 빠진 하나의 task만 실행되도록 할 수 있습니다.

```bash
# 해당 tag 만 실행
ansible-playbook -i hosts-vm playbook-step1.yml -t "pre, docker, k9s"
```

### Step3

role을 생성하여 좀 더 복잡한 설치를 수행할 수 있도록 합니다.

```bash
# role 생성
ansible-galaxy init test-role 
# tag list 조회
ansible-playbook -i hosts-vm playbook-step3.yml --list-tag 
# task list 조회
ansible-playbook -i hosts-vm playbook-step3.yml --list-tasks
# ex
ansible-playbook -i hosts-vm playbook-step3.yml -t "kubectl"
```

### Step4


```



```



```bash


```


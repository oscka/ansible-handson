# ansible-handson project

이 프로젝트는 K8S 및 관련 솔루션 설치 자동화를 위해 vagrant로 vm을 만들어 설치 대상서버로 사용하며, ansible로 대상에 솔루션 및 오픈소스를 설치하는 과정을 학습하기 위해 step별로 구성되어 있습니다.

핸즈온을 위해 미리 설치가 필요한 것들은 다음과 같습니다.

## 사전설치

핸즈온 실행을 위해 vagrant와 ansible은 사전 설치가 필요합니다.
ansible 버전은 가급적 맞추는 것이 좋습니다. 버전이 다를 경우 실행 자체가 되지 않는 경우가 있습니다.
(글 작성 시점-2022.09.10-기준)

- Vagrant(version 2.3.0) - https://www.vagrantup.com/downloads
- Ansible(version 2.13.4) -
  - 참고:(ubuntu에서 최신버전 설치하기)[https://www.cyberciti.biz/faq/how-to-install-and-configure-latest-version-of-ansible-on-ubuntu-linux/]

## 구성요소

- Vagrant - mac, window, linux OS플랫폼 별로 존재하나 vagrant로 구동될 OS는 ubuntu/focal64 공식 이미지를 사용합니다. 2개 vm을 실행하여 설치 과정을 테스트하며 수시로 삭제하고 재생성해야 합니다.
- ansible - 플랫폼을 가리지 않으나 가급적 mac혹은 linux를 사용하는 것을 권장합니다.

바깥의 OS -> 2개의 vm으로 ssh로 연결하여 ansible이 실행되며 이를 위해 vagrant의 ssh정보를 이용합니다.

ssh key조회를 위해서 vagrant ssh-config 를 통해 확인한 뒤 각 step의 hosts-vm안에 경로에 해당 key파일의 경로를 넣어야 ansible이 이를 통해 설치를 수행할 수 있습니다.

## 핸즈온 Steps

### step0(준비)

#### vm실행하기

test-vm1,test-vm2 디렉토리에는 Vagrant를 통해 실행되는 vm의 설정(Vagrantfile)들이 들어 있습니다. vagrant는 디렉토리 단위로 vm이 관리되며 연결된 provider(가상머신관리자)에 따라 각 가상머신을 생성하고 실행합니다. 일반적으로는 virtualbox를 많이 사용하며 로컬환경에 vagrant와 virtualbox가 설치되어 있다면 다음과 같이 가상머신을 up해주면 vm이 기동됩니다.

```bash
cd ./test-vm1
# 생성 및 기동
➜  test-vm1 git:(main) ✗ vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Importing base box 'ubuntu/focal64'...
==> default: Matching MAC address for NAT networking...
==> default: Checking if box 'ubuntu/focal64' version '20220905.0.0' is up to date...
==> default: A newer version of the box 'ubuntu/focal64' for provider 'virtualbox' is
==> default: available! You currently have version '20220905.0.0'. The latest is version
==> default: '20220913.0.0'. Run `vagrant box update` to update.
==> default: Setting the name of the VM: test-vm1
==> default: Clearing any previously set network interfaces...
==> default: Preparing network interfaces based on configuration...
    default: Adapter 1: nat
    default: Adapter 2: hostonly
==> default: Forwarding ports...
    default: 22 (guest) => 2222 (host) (adapter 1)
==> default: Running 'pre-boot' VM customizations...
==> default: Booting VM...
==> default: Waiting for machine to boot. This may take a few minutes...
(...)
# 정지
➜  test-vm1 git:(main) ✗ vagrant halt
# 삭제
➜  test-vm1 git:(main) ✗ vagrant destroy -f
==> default: Forcing shutdown of VM...
==> default: Destroying VM and associated drives...
~/git/oscka/ansible-handson/test-vm1
```

#### ssh 접속 설정하기

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

hosts-vm 파일은 각 step마다 들어 있으며 ansible의 작업 대상인 vm들을 정의합니다. 레이아웃은 다음과 같으며 ip,user,key 파일들을 로컬 환경에 맞게 수정해줘야 정상적으로 실행할 수 있습니다. 매번 명령 수행시 -i로 hosts-vm파일을 주어 참조합니다.

```
[vms] # 그룹명
# step1,step2는 host명, ansible_ssh_private_key_file 파일의 경로 주의
step1 ansible_host=192.168.56.10 ansible_user=vagrant ansible_port=22 ansible_ssh_private_key_file=/home/ska/git/oscka/ansible-handson/test-vm1/.vagrant/machines/default/virtualbox/private_key
step2 ansible_host=192.168.56.20 ansible_user=vagrant ansible_port=22 ansible_ssh_private_key_file=/home/ska/git/oscka/ansible-handson/test-vm2/.vagrant/machines/default/virtualbox/private_key
```

### Step1

step1은 단순히 kubectl을 구동중인 vm에 설치합니다.

```bash
# playbook 실행
ansible-playbook -i hosts-vm playbook-step1.yml
```

apt, shell등은 ansible의 builtin 모듈입니다. 기본 모듈이기 때문에 builtin.을 생략하고 작성할 수 있으며 각각 용도에 맞게 동작합니다.

```yaml
  - name: "[pre] apt update"
    # apt:
    #   update_cache: yes
    shell:
      apt update
    become: true  # root권한으로 하겠다
```

### Step2

step2는 Docker와 k9s를 설치하고 구동합니다. step1 보다는 다소 복잡한 작업을 수행합니다.

각 ansible task들은 tag를 지정할 수 있으며 차후 설치 편의를 위해 task마다 적당한 이름을 붙여 넣습니다.

tag는 여러개를 한번에 넣어 순차적으로 실행되도록 할 수도 있고, 빠진 하나의 task만 실행되도록 할 수 있습니다. tag를 특정하지 않을 경우 전체가 기본으로 수행됩니다.

```bash
# 해당 tag 만 실행
ansible-playbook -i hosts-vm playbook-step1.yml -t "pre, docker, k9s"
```

### Step3

Step3에서는 role을 기반으로 좀 더 구성화된 ansible 스크립트를 작성합니다.

ansible은 role을 생성하여 좀 더 복잡한 설치를 수행할 수 있도록 합니다. role은 ansible-galaxy라는 명령으로 생성하며 일종의 ansible을 위한 템플릿 프로젝트를 만들어 줍니다.(spring initializer 처럼)

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

role은 생성시 다음과 같은 구조와 용도를 가집니다.

```
├── hosts-vm
├── playbook-step3.yml
└── test-role
    ├── README.md
    ├── defaults       # role이 사용될 때 기본으로 사용되는 변수값
    │   └── main.yml
    ├── handlers       # 핸들러정보(차후)
    │   └── main.yml
    ├── meta           # 롤의 메타정보(라이센스 등)
    │   └── main.yml
    ├── tasks          # 실제 수행되는 태스크
    │   ├── k8s-tool
    │   │   └── k8s-tool.yml
    │   ├── main.yml  # 실제 수행될 메인 태스크
    │   └── pre-post.yml
    ├── tests          # 테스트(핸즈온에서는 무시)
    │   ├── inventory
    │   └── test.yml
    └── vars           # 가변적 상황(OS,환경 등)에 대한 변수값
        └── main.yml
```

### Step4

Step4에서는 k3d 기반으로 클러스터를 설치하고 클러스터에 argocd를 설치하여 cd환경을 구성하는 것 까지를 수행하며, 좀 더 편한 실행을 위해 shell script를 이용하여 제어합니다.

설치 및 테스트를 위해 playbooks 디렉토리 하위의 다음 shell script들을 이용합니다.

```bash
# 스크립트 실행(실행 권한이 없을 경우)
sh run-vm.sh
# 전체 설치
sh run-vm.sh "pre, ansible-module, helm-repo, k8s-basic, argocd"
# 핑 테스트
./show-ping-test.sh
# 태그 조회
./show-tags-run-all.sh
# 아래 옵션은 host에 대해 key를 등록한 적이 있는지를 확인하지 않음
export ANSIBLE_HOST_KEY_CHECKING=False
```

설치 스크립트는 step3와 동일하게 role로 구성됩니다.

defaults 에는 다음과 같이 기본 설정값들이 들어갑니다. "LOCAL_USER_HOME"의 변수는 로컬환경의 OS의 홈디렉토리로 수정해줘야 합니다.
INSTALL_DOWN_ROOT 경로는 설치시 받아지는 임시 다운로드 디렉토리라고 생각하시면 됩니다. 설치가 완료되면 삭제됩니다.

```yaml
(...)
INSTALL_DOWN_ROOT: /home/{{ ansible_user }}/dev-tools # 로컬 다운로드용 임시공간
LOCAL_USER_HOME: "/home/ska"  # 경로 로컬환경에 맞게 수정해야 함
(...)
```

다음과 같은 task를 통해 templates 하위의 jinja2 설정 템플릿을 복사하여 설정 디렉토리에 넣고 맞는 변수값들을 할당하여 줍니다.

```yaml
- name: k3d config-file  업로드 서버로
  template:
    src: k3d/k3d-config.yml.j2
    dest: "{{ component.INSTALL_ROOT }}/k3d/k3d-config.yml"
  tags: 
    - k3d-config-up
    - k3d 
    - k8s-basic
```

디버깅을 위해 output을 통해 실행 내용을 출력하도록 할 수 있습니다.

```yaml
#--[output]-- # 디버깅을 위해 등록
- debug:
    var: output
  tags: 
    - docker-restart
    - tool-basic
    - k8s-basic

- name: "k3d cli 설치"
  shell: |
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | TAG={{K3D_TAG_VER}} bash
    echo "============= k3d version ==============="
    k3d version
  register: output   ##디버깅을 위해 등록
  tags: 
    - k3d-cli
    - tool-basic
    - k8s-basic
```

task는 OS나 환경에 따라 실행되거나 되지 않도록 설정할 수 있습니다.

```yaml
- name: "[post] install dev-tools 폴더 삭제"
  file:   
    path: "{{ INSTALL_DOWN_ROOT }}"
    state: absent
  tags: post
  when: ansible_os_family == 'Debian'  # debian일때만 실행
```

설치 완료 후 로컬 -> VM의 클러스터로 접근하기 위해 다음과 같이 kubeconfig 설정을 해 줍니다. 설정시 로컬의 home디렉토리 경로에 맞게 지정되어야 합니다.

```bash
export KUBECONFIG=/home/ska/.kube/k8s/kubeconfig
```

이를 좀 더 편하게 하기 위해 direnv를 설치하여 ROOT경로에 해당 파일을 가져다 놓았습니다. 다음을 참고하여 사용하는 shell에 export 설정을 하고 이를 적용합니다.

```bash
# direnv 설치
## Ubuntu, Debian
$ apt-get install direnv

# direnv 적용
## ZSH -> ~/.zshrc에 아래 내용 추가
eval "$(direnv hook zsh)"

# direnv 사용 - 자동으로 .envrc 디렉토리 하위에 해당 shell 환경이 적용됨
# 아래와 같이 수동으로 로딩 가능
direnv allow

# 다음내용을 .envrc파일로 만들어 git root에 두고 적용
export KUBECONFIG=/home/ska/.kube/k8s/kubeconfig
```

그밖의 클러스터 설치 관련 사항들은 다음과 같습니다.

```yaml
# k3d-config.yml.j2
hostPort: "{{K3D_HOST_PORT}}"  # 설정하지 않으면 바뀜(고정시켜야..)
(...)
  k3s: 
    extraArgs: 
      - arg: --tls-san={{ansible_host}}  # --> 주의!!:넣어주어야 remote 접속할 수 있음

# argocd-ingress.yml.j2
kind: Ingress  ## 각각의 프로젝트 소속이 되어야 함(같이 배포)
(...)
- host: "{{ARGOCD_HOST}}"   ## 붙을 수 있는 도메인

# k8s-tool.yml

become: true      # root권한으로 실행 가능

  #--[output]-- 결과를 콘솔에 출력
  - debug:
      var: output
    tags: 
      - docker-restart
      - tool-basic
      - k8s-basic

  # fact를 실행하여 출력
  - name: Print all available facts
    ansible.builtin.debug:
      var: ansible_facts
    tags: 
      - facts

# dev-k8s.yml

    k3d cluster create --config  {{ component.INSTALL_ROOT }}/k3d/k3d-config.yml --wait # --wait는 클러스터 생성 완료까지 대기
    k3d kubeconfig write {{K3D_ClUSTER_NAME}}  # KUBECONFIG 파일을 작성하여 줌

  # pod가 ready일 때까지 대기
  - name: waiting for pod status Ready
    shell: |
        kubectl wait pod --timeout=-1s --for=condition=Ready -l '!job-name' -n kube-system
    tags: 
      - k3d
      - k8s-basic


  shell: |
    k3d cluster create {{K3D_ClUSTER_NAME}}  \ 
        --agents {{K3D_AGENT}} \     # node갯수를 지정
        -p 80:80@loadbalancer \      # 안,밖의 port를 연결(k3d는 k3s기반이며 k3s에서는 @loadbalancer를 붙여야 포트가 포워딩됨)
        -p 443:443@loadbalancer \
        -p {{K3D_EXTRA_PORT1}}:{{K3D_EXTRA_PORT1}}@loadbalancer \  # 3만대 이상은 NODEPORT이며 하드코딩(대안으로ingress를 잡는다)
        -p {{K3D_EXTRA_PORT2}}:{{K3D_EXTRA_PORT2}}@loadbalancer \
        -p {{K3D_EXTRA_PORT3}}:{{K3D_EXTRA_PORT3}}@loadbalancer \
        -p {{K3D_EXTRA_PORT4}}:{{K3D_EXTRA_PORT4}}@loadbalancer \
        {{K3D_OPTIONS1}} --wait   # K3D는 traefik이 기본이며 diasble(nginx로 대체)

  # remote의 kubeconfig 파일을 로컬로 가져옴(원격 접속을 위해)
  - name: "k3d fetch remote kubeconfig"
    ansible.builtin.fetch:
      src: "/home/{{ansible_user}}/.k3d/kubeconfig-{{K3D_ClUSTER_NAME}}.yaml"
      dest: "{{LOCAL_USER_HOME}}/.kube/k8s/kubeconfig"
      flat: yes # 없으면 가져와서 만들어서 넣어 줌
    tags: 

    sed -i '' 's/0.0.0.0/{{ansible_host}}/' {{LOCAL_USER_HOME}}/.kube/k8s/kubeconfig  # 앞의 ''은 백업하지 말라는 의미

# ingress-controller.yml

  when: INGRESS_NGINX_ENABLE_SSLPASSTHROUGH == 'Y'  # 복호화를 하지 않고 https 요청 자체를 넘김  

```

### Step5

Step5에서는 k3s로 클러스터를 구성하고 argocd로 api, fe 프로젝트를 배포하며 이를 모니터링(loki, grafana, pinpoint)하는 부분까지를 설치하고 테스트 할 수 있습니다.

Step5는 내용이 많아 별도의 문서로 기술합니다. [Step5](./step5/README.md)

### Step6

Step6에서는 Multi Master Cluster를 구성하는 방법을 설명합니다.

Step6 역시 별도의 문서로 기술합니다. - [Step6 로 이동](./step6/README.md)

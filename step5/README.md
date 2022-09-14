# Step5

Step5에서는 k3s로 클러스터를 구성하고 argocd로 api, fe 프로젝트를 배포하며 이를 모니터링(loki, grafana, pinpoint)하는 부분까지를 설치하고 테스트 할 수 있습니다.

## 구성

이 ansible 설치 프로젝트는 다음과 같은 구성요소들을 설치합니다.

기본 도구, helm

ingress-nginx, argocd, loki-stack(grafana), pinpoint, mysql, 

demo-api,demo-fe

## 실행

실행 전 다음과 같은 파일의 로컬 실행 경로를 확인하여 수정해 둡니다.

```

# step5/roles/role-k8s-apps/defaults/main.yml 의 다음 내용을 로컬환경 경로에 맞게 수정
#LOCAL_USER_HOME: "/Users/blackstar"
LOCAL_USER_HOME: "/home/ska"

#playbook-run-all.yml의 다음 내용을 경로에 맞게 수정
  vars:
    - ROLES_PATH: /home/ska/git/oscka/ansible-handson/step5/roles

```

이후 playbook 하위 경로에서 다음과 같이 실행하여 설치를 실행할 수 있습니다.

```
./run-play.sh  "tool-basic, helm-repo,k3s, ingress-nginx, argocd,   loki-stack, pinpoint, mysql, demo-api-argocd,demo-fe-argocd"
```

## 확인

### 서비스 확인 및 테스트

다음과 같은 주소에서 각 서비스에 접속하여 확인할 수 있으며 접속하여 그 결과를 확인합니다.

**접속주소**

- argocd - https://argocd.192.168.56.10.sslip.io
- fe app - http://demo-fe.192.168.56.10.sslip.io/list
- grafana - http://grafana.192.168.56.10.sslip.io
- pinpoint - http://pinpoint.192.168.56.10.sslip.io
- mysql - mysql.192.168.56.10.sslip.io:3306 (DB는 tcp로 접속해야 함)

**loki 기반으로 로그 확인하기**

grafana 접속 후 좌측 메뉴의 explorer - Log Browser 선택한 뒤 namespace 기반으로 조회(또는 app 기반으로 조회)

-> 정상적으로 api,fe 서비스의 로그가 조회되는지 확인(미리 요청을 해 두어야 함)

**fe app 동작여부 확인**

**pinpoint 접속하여 APM 및 서버 모니터링 결과 확인**

**mysql client를 통한 DB접속 확인**

## 그밖의 내용들

### Ansible 전역 설정 추가하기

ssh 연결시 로컬의 공개키를 서버에 등록되어 있는지 확인하고 등록되어 있지 않으면 이를 등록하는 과정을 거치게 되는데, 이는 정상적으로 접속시에는 별 문제가 되지 않지만 프로그램을 통해 작업시에는 오류를 발생시키는 원인이 되기도 합니다.
ansible을 통해 작업시 ssh-key를 확인하는 절차를 생략하는 방법은 여러가지가 있습니다.

**SHELL의 환경변수로 export**

아래와 같은 내용을 현재 세션에 적용하거나, bashrc/zshrc 등에 추가하여 로그인 시 마다 적용될 수 있도록 합니다.

```bash
export ANSIBLE_HOST_KEY_CHECKING=False
```

**direnv를 이용하는 방법**

direnv를 이용하여 위 shell 설정을 .envrc에 넣어 하위 디렉토리에 적용되도록 한다.

**ansible의 전역 설정에 추가하는 방법**

ansible 전역 설정 파일을 열어 아래 내용을 추가한다.

### External Vars(외부 변수) 활용하는 방법

기본적으로 ansible playbook 실행시 default 하위의 변수들을 참조하도록 되어 있으나 동일한 값을 External Var에 두고 해당 값을 참조하도록 할 수 있다

실행환경 별로 별도로 두어 실행시에 참조를 바꿀 수 있다.

```
# os별로 혹은 환경별로 external-vars 를 만들어 실행할 수 있음
ansible-playbook -i hosts-vm  playbook-run-all.yml -t "$TAGS" -e "@external-vars.yml"
```

### promtail 설정방법

promtail-config -> 변경 후 argocd 네임스페이스도 보이는 지 확인(external-vars 변경 확인 후)
promtail을 secret으로 만들어 특정 공간에 떨군 후 해당 파일을 적용하는 형태로 사용하였음

### argocd에서 yaml로 배포

argocd 상에서 어플리케이션 자체도 yaml형태로 설치할 수 있음 -> kubectl 명령어로 application을 배포 가능

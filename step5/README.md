# Step5

Step5에서는 k3s로 클러스터를 구성하고 argocd로 api, fe 프로젝트를 배포하며 이를 모니터링(loki, grafana, pinpoint)하는 부분까지를 설치하고 테스트 할 수 있습니다.

## 구성

이 ansible 설치 프로젝트는 다음과 같은 구성요소들을 설치합니다.

- 기본 도구성 유틸, helm3
- k3s 클러스터, ingress-nginx
- ingress-nginx, argocd, loki-stack(grafana), pinpoint, mysql
- demo-api,demo-fe

vagrant를 통하여 설치하거나, aws 등의 클라우드 환경에서 ansible을 통해 설치할 수 있습니다.

(설치 대상 vm은 2 core, 8 GB ram 이상의 사양 필요하며 vagrant, aws lightsail, azure에서 테스트 완료하였음)

## 실행

실행 전 다음과 같은 파일의 로컬 실행 경로를 확인하여 수정해 둡니다.

```

# step5/roles/role-k8s-apps/defaults/main.yml 의 다음 내용을 로컬환경 경로에 맞게 수정
#LOCAL_USER_HOME: "/Users/blackstar"
LOCAL_USER_HOME: "/home/$USER"

# playbook-run-all.yml의 다음 내용을 경로에 맞게 수정
  vars:
    - ROLES_PATH: /home/ska/git/oscka/ansible-handson/step5/roles

```

이후 playbook 하위 경로에서 다음과 같이 실행하여 설치를 실행할 수 있습니다.

```bash
./run-play.sh  "tool-basic, helm-repo,k3s, ingress-nginx, argocd, loki-stack, pinpoint, mysql, demo-api-argocd,demo-fe-argocd"
```

오류가 발생할 경우 오류가 발생한 시점 이후의 tag를 확인하여 해당 부분만 재실행하는 방식으로 설치를 이어 갈 수 있습니다.

## 확인

### 서비스 확인 및 테스트

설치 완료 후 다음과 같은 주소에서 각 서비스에 접속하여 확인할 수 있으며 접속하여 그 결과를 확인합니다.

**접속주소(vm에 설치시에는 해당 공인IP가 중간에 들어감)**

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

**mysql client를 통한 DB접속 확인 - ingress를 통해 TCP 내부접속 가능**

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

direnv를 이용하여 위 shell 설정을 .envrc에 넣어 하위 디렉토리에 적용되도록 합니다.

**ansible의 전역 설정에 추가하는 방법**

ansible 전역 설정 파일을 열어 아래 내용을 추가합니다.

```
# /etc/ansible/ansible.cfg 하단에 추가
[defaults]
host_key_checking = False
```

### External Vars(외부 변수) 활용하는 방법

기본적으로 ansible playbook 실행시 default 하위의 변수들을 참조하도록 되어 있으나 동일한 값을 External Var에 두고 해당 값을 참조하도록 할 수 있습니다

이를 활용하여 실행환경 별로 별도로 분리하여 실행시에 참조를 환경에 맞게 바꿀 수 있습니다.

```
# os별로 혹은 환경별로 external-vars 를 만들어 실행할 수 있음
ansible-playbook -i hosts-vm  playbook-run-all.yml -t "$TAGS" -e "@external-vars.yml"
```

### promtail 설정방법

promtail은 loki, grafana와 함께 로그를 통합 모니터링 할수 있게 해주는 도구입니다.

이 스크립트에서는 다음과 같이 promtail 설정을 secret으로 만들어 특정 공간에 떨군 후 해당 파일을 적용하는 형태로 사용하였습니다.(promtail-secret-data.j2)

```yaml
- name: promtail SECRET 생성 
  kubernetes.core.k8s:
    state: present
    definition: 
      apiVersion: v1
      kind: Secret
      type: Opaque   
      metadata:
        name: "{{ PROMTAIL_SECRET_NAME }}"
        namespace: "{{ PROMTAIL_NAMESPACE | lower }}"   
      data:
        promtail.yaml: "{{ lookup('template', PROMTAIL_TEMPLATES_PATH + '/promtail-secret-data.j2' ) | b64encode }}"
  register: output
  tags: 
    - promtail-config
    - promtail
    - loki-stack
    - demo-ex
    - demo-ex-argocd
```

promtail-config를 변경할 경우 다음과 같이 작업합니다.

```bash
# external-vars.yml 파일에 다음 내용을 추가(기존에는 api|fe만 존재)
PROMTAIL_MATCH_SELECTOR: '{namespace !~ "api|fe|argocd"}'  ## api, fe namespace 외는 모두 drop 한다

# 위 내용을 다시 ansible을 통해 해당 tag만 실행
./run-play.sh  "promtail-config"

```

### argocd에서 yaml로 배포

일반적으로 argocd 상에서는 GUI를 통해 repository를 등록하고 app을 생성하는 작업을 수행하는데, 이를 argocd 상에서 yaml형태로 두고 kubectl 명령어로 application을 배포하도록 구성할 수 있습니다. 해당 스크립트에서는 이를 jinja2 템플릿으로 두고 yaml을 설정한 뒤 배포하도록 구성하였습니다.

```yaml
# demo-api-argocd-apps.yml.j2
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: demo-api
  namespace: argocd
  finalizers:
  - resources-finalizer.argocd.argoproj.io 
spec:
  destination:
    server: https://kubernetes.default.svc
    namespace: {{DEMO_API_NAMESPACE}}
  project: default
  source:
    repoURL: 'https://github.com/io203/demo-ops.git'
    path: demo-api/{{DEMO_API_ARGOCD_DEPLOY_TYPE}}
    targetRevision: {{DEMO_API_ARGOCD_TARGET_REVISION}}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

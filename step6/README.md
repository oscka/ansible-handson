# Step6

Step6에서는 Multi master k8s 설치를 해 봅니다.

**~~주의!!!! : 이 단계는 2022년 9월 21일 현재 vagrant기반에서 설치시 master join 할때 [오류](vagrant_error.md)가 발생합니다. 별도 클라우드환경(AWS)에서 설치하여 테스트시에는 이상없이 동작합니다.~~** (수정됨)

## 준비사항

VM이 총 6대 필요합니다.

- 메모리 3G의 master node를 위한 VM 3대(master1, master2, master3)
- 메모리 2G worker node를 위한 VM 2대(worker1, worker2)
- 메모리 1G lb(loadbalancer) node를 위한 VM 1대

스크립트 실행 전 아래와 같은 부분을 로컬 환경(경로 및 환경)에 맞게 수정해야 합니다.

- step6/playbook-cluster/playbook-k8s-cluster/playbook-k8s-cluster.yml : Role 경로 수정
- step6/roles/k8s-cluster/role-k8s-master/defaults/main.yml

## 소개

본 Step에서는 K8S 운영환경을 위한 multi master 아키텍처 환경을 설치합니다.

설치 후 worker node들은 3개의 master 중에 Leader로 먼저 접속하게 되며, 각 master node에 etcd를 각각 가지고 있습니다. master의 가용성을 위해 LB를 통해 접속하는 구성입니다.

멀티 master 클러스터를 위해서는 CNI(Cloud Network Interface-Flannel, Calico, Weavenet 등등이 있음)가 필요하며 여기서는 Calico를 사용하여 구성합니다.

vagrant일때는 상관 없으나 AWS등 원격 환경일 경우 LB, 각 마스터 서버(master1-3) 에 6443 포트 방화벽 허용필요(worker는 필요 없음)합니다.

## Single master 클러스터 설치

우선 Single master 클러스터를 다음과 같이 설치합니다. 1,2번 과정은 multi master 설정과 동일합니다.

```bash
# 1.master하고 work node(5개) kube계정 생성 및 공개키 등록(1,2 실행시에는 hosts-k8s파일[인벤토리]의 masters,workers 그룹을 막고 실행해야 함)
./run-aws-k8s-cluster.sh "k8s-pre, k8s-user"

# 2.hosts-k8s의 하단 부분을 풀고 계정을 kube로 변경(1,2 실행시에는 hosts-k8s파일[인벤토리]의 masters,workers 그룹을 막고 실행해야 함)
./run-aws-k8s-cluster.sh "k8s-tools"

# 3.싱글 master설치를 위해 master2,3을 막고 아래와 같이 실행
./run-aws-k8s-cluster.sh "k8s-cluster-single"

# 설치 완료 후 다음과 같이 확인
$ k get nodes
NAME         STATUS   ROLES           AGE     VERSION
vm-master1   Ready    control-plane   7m45s   v1.24.4
vm-worker1   Ready    `<none>`          7m12s   v1.24.4
vm-worker2   Ready    `<none>`          6m54s   v1.24.4
$ k get pod -A
NAMESPACE     NAME                                       READY   STATUS              RESTARTS      AGE
kube-system   calico-kube-controllers-7fc4577899-sbxc6   0/1     ContainerCreating   0             7m49s
kube-system   calico-node-2fmwl                          1/1     Running             0             7m49s
kube-system   calico-node-djmff                          0/1     Running             5 (46s ago)   7m33s
kube-system   calico-node-k7ksj                          0/1     Running             5 (23s ago)   7m15s
kube-system   coredns-6d4b75cb6d-lcrxt                   1/1     Running             0             7m49s
kube-system   coredns-6d4b75cb6d-xxfh4                   1/1     Running             0             7m49s
kube-system   etcd-vm-master1                            1/1     Running             0             8m2s
kube-system   kube-apiserver-vm-master1                  1/1     Running             0             8m2s
kube-system   kube-controller-manager-vm-master1         1/1     Running             0             8m2s
kube-system   kube-proxy-9mjh6                           1/1     Running             0             7m15s
kube-system   kube-proxy-jcbjt                           1/1     Running             0             7m49s
kube-system   kube-proxy-sx22q                           1/1     Running             0             7m33s

#실행 완료 후 아래와 같이 삭제
./run-aws-k8s-cluster.sh "k8s-cluster-single-delete"
```

Single Master 설치 작업의 내용은 다음과 같습니다.

```
1. apt update
2. kube 
3. containerd 설치(컨테이너 엔진 관리기능)
4. kubectl, kubeadm, kubelet 설치
5. single master 설치
6. worker node 설치

```

## Multi master 클러스터 설치

다음과 같이 multi master가 있는 클러스터 환경을 설치합니다. 1,2번 과정은 single master 설정과 동일합니다.

```bash
# 1.master하고 work node(5개) kube계정 생성 및 공개키 등록(1,2 실행시에는 hosts-k8s파일[인벤토리]의 masters,workers 그룹을 막고 실행해야 함)
./run-aws-k8s-cluster.sh "k8s-pre, k8s-user"

# 2.hosts-k8s의 하단 부분(kube계정)을 풀고 계정을 kube로 변경(1,2 실행시에는 hosts-k8s파일[인벤토리]의 masters,workers 그룹을 막고 실행해야 함)
./run-aws-k8s-cluster.sh "k8s-tools"

# 3.멀티 master설치를 위해 아래와 같이 실행(hosts-k8s파일[인벤토리]의 전체가 열려있는 상태로 실행)
./run-aws-k8s-cluster.sh "k8s-cluster-multi-pre, k8s-cluster-multi"

# 설치 완료 후 다음과 같이 확인
❯ k get pod -A
NAMESPACE     NAME                                       READY   STATUS     RESTARTS   AGE
kube-system   calico-kube-controllers-6799f5f4b4-jt6sz   1/1     Running    0          114s
kube-system   calico-node-s9t5q                          0/1     Init:2/3   0          44s
kube-system   calico-node-x4zmv                          1/1     Running    0          114s
kube-system   coredns-6d4b75cb6d-bsbwn                   1/1     Running    0          114s
kube-system   coredns-6d4b75cb6d-g26r9                   1/1     Running    0          114s
kube-system   etcd-vm-master1                            1/1     Running    0          2m7s
kube-system   etcd-vm-master2                            1/1     Running    0          33s
kube-system   kube-apiserver-vm-master1                  1/1     Running    0          2m7s
kube-system   kube-apiserver-vm-master2                  1/1     Running    0          23s
kube-system   kube-controller-manager-vm-master1         1/1     Running    0          2m7s
kube-system   kube-controller-manager-vm-master2         1/1     Running    0          34s
kube-system   kube-proxy-kgnqt                           1/1     Running    0          114s
kube-system   kube-proxy-wllc9                           1/1     Running    0          44s
kube-system   kube-scheduler-vm-master1                  1/1     Running    0          2m7s
kube-system   kube-scheduler-vm-master2                  1/1     Running    0          31s

# multi master의 경우 참여한 master의 role이 contol-plane으로 표시되는 지 확인합니다.
❯ kubectl get node
NAME         STATUS   ROLES           AGE     VERSION
vm-master1   Ready    control-plane   2m15s   v1.24.4
vm-master2   Ready    control-plane   50s     v1.24.4
```

loadbalancer는 docker를 설치한 뒤 ha-proxy를 띄워 클러스터 설정을 위해 각 master node를 볼 수 있도록 설정합니다.

각 master 및 work에서는 loadbalancer 향해 요청을 보내고 설정을 수행합니다. 실제 상세 작업 내역은 다음과 같습니다.

```
1. lb -> ha-proxy를 docker 기반으로 생성
2. master1 생성, join script 생성
3. master2 에서 join
4. master3에서 join
5. worker1에서 join(lb로)
6. worker2에서 join(lb로)

```

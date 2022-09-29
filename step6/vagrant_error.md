step6에서 multi cluster 기반으로 설치시 아래와 같은 에러가 발생함

```bash
kube@vm-master2:~$ sudo kubeadm join 192.168.56.23:6443 --token hm2xyu.uxewpwicpljbx47o --discovery-token-ca-cert-hash sha256:b15def6e414011d5665d3d1f03731f591b61e480dab292c54d564ea2bc544be6    --control-plane --certificate-key 5e6eb6ba0d4a7d09dbab48bb5925166da3b1779944893b0370b68a9218bd74c8
[preflight] Running pre-flight checks
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[preflight] Running pre-flight checks before initializing the new control plane instance
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[download-certs] Downloading the certificates in Secret "kubeadm-certs" in the "kube-system" Namespace
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Using the existing "apiserver-kubelet-client" certificate and key
[certs] Using the existing "apiserver" certificate and key
[certs] Using the existing "etcd/peer" certificate and key
[certs] Using the existing "etcd/healthcheck-client" certificate and key
[certs] Using the existing "apiserver-etcd-client" certificate and key
[certs] Using the existing "etcd/server" certificate and key
[certs] Using the existing "front-proxy-client" certificate and key
[certs] Valid certificates and keys now exist in "/etc/kubernetes/pki"
[certs] Using the existing "sa" key
[kubeconfig] Generating kubeconfig files
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Using existing kubeconfig file: "/etc/kubernetes/admin.conf"
[kubeconfig] Using existing kubeconfig file: "/etc/kubernetes/controller-manager.conf"
[kubeconfig] Using existing kubeconfig file: "/etc/kubernetes/scheduler.conf"
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[check-etcd] Checking that the etcd cluster is healthy
```


상세원인 - virtualbox에서 NAT용으로 잡는 네트워크 인터페이스를 etcd에서 접근시 사용하여 접속하려고 하나 접속이 안되어 오류가 발생함. 외부 클라우드 환경에 설치시에는 문제가 없음

```bash
# 상세로그
vagrant@vm-master2:/tmp$ sudo kubeadm join 192.168.56.23:6443 --token 4o2tfs.lb14929ssh4vtbxo         --discovery-token-ca-cert-hash sha256:35c436cc2e34c3e295488c1f97752bd38e2880c6fcff23b8e51569bb822a8339         --control-plane --certificate-key 07075df9341f88c4a33a69ea83e8a90a019bdc2b4b6ada6ed36970f3d944bc05 --v=5
I0922 06:13:43.185517   35791 join.go:403] [preflight] found /etc/kubernetes/admin.conf. Use it for skipping discovery
I0922 06:13:43.186071   35791 join.go:413] [preflight] found NodeName empty; using OS hostname as NodeName
I0922 06:13:43.186089   35791 join.go:417] [preflight] found advertiseAddress empty; using default interface's IP address as advertiseAddress
I0922 06:13:43.186240   35791 initconfiguration.go:117] detected and using CRI socket: unix:///var/run/containerd/containerd.sock
I0922 06:13:43.186386   35791 interface.go:432] Looking for default routes with IPv4 addresses
I0922 06:13:43.186391   35791 interface.go:437] Default route transits interface "enp0s3"
I0922 06:13:43.186484   35791 interface.go:209] Interface enp0s3 is up
I0922 06:13:43.186531   35791 interface.go:257] Interface "enp0s3" has 2 addresses :[10.0.2.15/24 fe80::fe:c0ff:fe34:c3ed/64].
I0922 06:13:43.186556   35791 interface.go:224] Checking addr  10.0.2.15/24.
I0922 06:13:43.186567   35791 interface.go:231] IP found 10.0.2.15
I0922 06:13:43.186573   35791 interface.go:263] Found valid IPv4 address 10.0.2.15 for interface "enp0s3".
I0922 06:13:43.186578   35791 interface.go:443] Found active IP 10.0.2.15
[preflight] Running pre-flight checks
I0922 06:13:43.186655   35791 preflight.go:92] [preflight] Running general checks
I0922 06:13:43.186700   35791 checks.go:282] validating the existence of file /etc/kubernetes/kubelet.conf
I0922 06:13:43.186714   35791 checks.go:282] validating the existence of file /etc/kubernetes/bootstrap-kubelet.conf
I0922 06:13:43.186721   35791 checks.go:106] validating the container runtime
I0922 06:13:43.206072   35791 checks.go:331] validating the contents of file /proc/sys/net/bridge/bridge-nf-call-iptables
I0922 06:13:43.206154   35791 checks.go:331] validating the contents of file /proc/sys/net/ipv4/ip_forward
I0922 06:13:43.206171   35791 checks.go:646] validating whether swap is enabled or not
I0922 06:13:43.206202   35791 checks.go:372] validating the presence of executable crictl
I0922 06:13:43.206223   35791 checks.go:372] validating the presence of executable conntrack
I0922 06:13:43.206232   35791 checks.go:372] validating the presence of executable ip
I0922 06:13:43.206247   35791 checks.go:372] validating the presence of executable iptables
I0922 06:13:43.206272   35791 checks.go:372] validating the presence of executable mount
I0922 06:13:43.206291   35791 checks.go:372] validating the presence of executable nsenter
I0922 06:13:43.206312   35791 checks.go:372] validating the presence of executable ebtables
I0922 06:13:43.206324   35791 checks.go:372] validating the presence of executable ethtool
I0922 06:13:43.206334   35791 checks.go:372] validating the presence of executable socat
I0922 06:13:43.206345   35791 checks.go:372] validating the presence of executable tc
I0922 06:13:43.206356   35791 checks.go:372] validating the presence of executable touch
I0922 06:13:43.206394   35791 checks.go:518] running all checks
I0922 06:13:43.215802   35791 checks.go:403] checking whether the given node name is valid and reachable using net.LookupHost
I0922 06:13:43.215932   35791 checks.go:612] validating kubelet version
I0922 06:13:43.261304   35791 checks.go:132] validating if the "kubelet" service is enabled and active
I0922 06:13:43.270261   35791 checks.go:205] validating availability of port 10250
I0922 06:13:43.270412   35791 checks.go:432] validating if the connectivity type is via proxy or direct
I0922 06:13:43.270443   35791 join.go:544] [preflight] Fetching init configuration
I0922 06:13:43.270459   35791 join.go:590] [preflight] Retrieving KubeConfig objects
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
I0922 06:13:43.285716   35791 kubelet.go:92] attempting to download the KubeletConfiguration from the new format location (UnversionedKubeletConfigMap=true)
I0922 06:13:43.290108   35791 interface.go:432] Looking for default routes with IPv4 addresses
I0922 06:13:43.290126   35791 interface.go:437] Default route transits interface "enp0s3"
I0922 06:13:43.290200   35791 interface.go:209] Interface enp0s3 is up
I0922 06:13:43.290241   35791 interface.go:257] Interface "enp0s3" has 2 addresses :[10.0.2.15/24 fe80::fe:c0ff:fe34:c3ed/64].
I0922 06:13:43.290254   35791 interface.go:224] Checking addr  10.0.2.15/24.
I0922 06:13:43.290259   35791 interface.go:231] IP found 10.0.2.15
I0922 06:13:43.290264   35791 interface.go:263] Found valid IPv4 address 10.0.2.15 for interface "enp0s3".
I0922 06:13:43.290270   35791 interface.go:443] Found active IP 10.0.2.15
I0922 06:13:43.293266   35791 preflight.go:103] [preflight] Running configuration dependant checks
[preflight] Running pre-flight checks before initializing the new control plane instance
I0922 06:13:43.293314   35791 checks.go:570] validating Kubernetes and kubeadm version
I0922 06:13:43.293326   35791 checks.go:170] validating if the firewall is enabled and active
I0922 06:13:43.300210   35791 checks.go:205] validating availability of port 6443
I0922 06:13:43.300285   35791 checks.go:205] validating availability of port 10259
I0922 06:13:43.300300   35791 checks.go:205] validating availability of port 10257
I0922 06:13:43.300315   35791 checks.go:282] validating the existence of file /etc/kubernetes/manifests/kube-apiserver.yaml
I0922 06:13:43.300332   35791 checks.go:282] validating the existence of file /etc/kubernetes/manifests/kube-controller-manager.yaml
I0922 06:13:43.300336   35791 checks.go:282] validating the existence of file /etc/kubernetes/manifests/kube-scheduler.yaml
I0922 06:13:43.300340   35791 checks.go:282] validating the existence of file /etc/kubernetes/manifests/etcd.yaml
I0922 06:13:43.300344   35791 checks.go:432] validating if the connectivity type is via proxy or direct
I0922 06:13:43.300360   35791 checks.go:471] validating http connectivity to first IP address in the CIDR
I0922 06:13:43.300376   35791 checks.go:471] validating http connectivity to first IP address in the CIDR
I0922 06:13:43.300381   35791 checks.go:205] validating availability of port 2379
I0922 06:13:43.300400   35791 checks.go:205] validating availability of port 2380
I0922 06:13:43.300413   35791 checks.go:245] validating the existence and emptiness of directory /var/lib/etcd
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
I0922 06:13:43.300647   35791 checks.go:834] using image pull policy: IfNotPresent
I0922 06:13:43.319747   35791 checks.go:843] image exists: k8s.gcr.io/kube-apiserver:v1.24.6
I0922 06:13:43.339928   35791 checks.go:843] image exists: k8s.gcr.io/kube-controller-manager:v1.24.6
I0922 06:13:43.359267   35791 checks.go:843] image exists: k8s.gcr.io/kube-scheduler:v1.24.6
I0922 06:13:43.380515   35791 checks.go:843] image exists: k8s.gcr.io/kube-proxy:v1.24.6
I0922 06:13:43.399775   35791 checks.go:843] image exists: k8s.gcr.io/pause:3.7
I0922 06:13:43.419176   35791 checks.go:843] image exists: k8s.gcr.io/etcd:3.5.3-0
I0922 06:13:43.438618   35791 checks.go:843] image exists: k8s.gcr.io/coredns/coredns:v1.8.6
[download-certs] Downloading the certificates in Secret "kubeadm-certs" in the "kube-system" Namespace
[certs] Using certificateDir folder "/etc/kubernetes/pki"
I0922 06:13:43.443690   35791 certs.go:47] creating PKI assets
I0922 06:13:43.443937   35791 certs.go:522] validating certificate period for etcd/ca certificate
I0922 06:13:43.645425   35791 certs.go:522] validating certificate period for etcd/server certificate
[certs] Using the existing "etcd/server" certificate and key
I0922 06:13:43.715549   35791 certs.go:522] validating certificate period for etcd/healthcheck-client certificate
[certs] Using the existing "etcd/healthcheck-client" certificate and key
I0922 06:13:44.129797   35791 certs.go:522] validating certificate period for apiserver-etcd-client certificate
[certs] Using the existing "apiserver-etcd-client" certificate and key
I0922 06:13:44.375535   35791 certs.go:522] validating certificate period for etcd/peer certificate
[certs] Using the existing "etcd/peer" certificate and key
I0922 06:13:44.375731   35791 certs.go:522] validating certificate period for ca certificate
I0922 06:13:44.439303   35791 certs.go:522] validating certificate period for apiserver-kubelet-client certificate
[certs] Using the existing "apiserver-kubelet-client" certificate and key
I0922 06:13:44.519982   35791 certs.go:522] validating certificate period for apiserver certificate
[certs] Using the existing "apiserver" certificate and key
I0922 06:13:44.520119   35791 certs.go:522] validating certificate period for front-proxy-ca certificate
I0922 06:13:44.856663   35791 certs.go:522] validating certificate period for front-proxy-client certificate
[certs] Using the existing "front-proxy-client" certificate and key
[certs] Valid certificates and keys now exist in "/etc/kubernetes/pki"
I0922 06:13:44.856800   35791 certs.go:78] creating new public/private key files for signing service account users
[certs] Using the existing "sa" key
[kubeconfig] Generating kubeconfig files
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Using existing kubeconfig file: "/etc/kubernetes/admin.conf"
[kubeconfig] Using existing kubeconfig file: "/etc/kubernetes/controller-manager.conf"
[kubeconfig] Using existing kubeconfig file: "/etc/kubernetes/scheduler.conf"
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
I0922 06:13:45.319649   35791 manifests.go:99] [control-plane] getting StaticPodSpecs
I0922 06:13:45.319788   35791 certs.go:522] validating certificate period for CA certificate
I0922 06:13:45.319841   35791 manifests.go:125] [control-plane] adding volume "ca-certs" for component "kube-apiserver"
I0922 06:13:45.319849   35791 manifests.go:125] [control-plane] adding volume "etc-ca-certificates" for component "kube-apiserver"
I0922 06:13:45.319853   35791 manifests.go:125] [control-plane] adding volume "etc-pki" for component "kube-apiserver"
I0922 06:13:45.319856   35791 manifests.go:125] [control-plane] adding volume "k8s-certs" for component "kube-apiserver"
I0922 06:13:45.319860   35791 manifests.go:125] [control-plane] adding volume "usr-local-share-ca-certificates" for component "kube-apiserver"
I0922 06:13:45.319869   35791 manifests.go:125] [control-plane] adding volume "usr-share-ca-certificates" for component "kube-apiserver"
I0922 06:13:45.321780   35791 manifests.go:154] [control-plane] wrote static Pod manifest for component "kube-apiserver" to "/etc/kubernetes/manifests/kube-apiserver.yaml"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
I0922 06:13:45.321806   35791 manifests.go:99] [control-plane] getting StaticPodSpecs
I0922 06:13:45.321985   35791 manifests.go:125] [control-plane] adding volume "ca-certs" for component "kube-controller-manager"
I0922 06:13:45.322007   35791 manifests.go:125] [control-plane] adding volume "etc-ca-certificates" for component "kube-controller-manager"
I0922 06:13:45.322013   35791 manifests.go:125] [control-plane] adding volume "etc-pki" for component "kube-controller-manager"
I0922 06:13:45.322017   35791 manifests.go:125] [control-plane] adding volume "flexvolume-dir" for component "kube-controller-manager"
I0922 06:13:45.322022   35791 manifests.go:125] [control-plane] adding volume "k8s-certs" for component "kube-controller-manager"
I0922 06:13:45.322028   35791 manifests.go:125] [control-plane] adding volume "kubeconfig" for component "kube-controller-manager"
I0922 06:13:45.322033   35791 manifests.go:125] [control-plane] adding volume "usr-local-share-ca-certificates" for component "kube-controller-manager"
I0922 06:13:45.322038   35791 manifests.go:125] [control-plane] adding volume "usr-share-ca-certificates" for component "kube-controller-manager"
I0922 06:13:45.324168   35791 manifests.go:154] [control-plane] wrote static Pod manifest for component "kube-controller-manager" to "/etc/kubernetes/manifests/kube-controller-manager.yaml"
[control-plane] Creating static Pod manifest for "kube-scheduler"
I0922 06:13:45.324196   35791 manifests.go:99] [control-plane] getting StaticPodSpecs
I0922 06:13:45.324719   35791 manifests.go:125] [control-plane] adding volume "kubeconfig" for component "kube-scheduler"
I0922 06:13:45.325277   35791 manifests.go:154] [control-plane] wrote static Pod manifest for component "kube-scheduler" to "/etc/kubernetes/manifests/kube-scheduler.yaml"
[check-etcd] Checking that the etcd cluster is healthy
I0922 06:13:45.325894   35791 local.go:71] [etcd] Checking etcd cluster health
I0922 06:13:45.325921   35791 local.go:74] creating etcd client that connects to etcd pods
I0922 06:13:45.325928   35791 etcd.go:168] retrieving etcd endpoints from "kubeadm.kubernetes.io/etcd.advertise-client-urls" annotation in etcd Pods
I0922 06:13:45.331592   35791 etcd.go:104] etcd endpoints read from pods: https://10.0.2.15:2379
context deadline exceeded
error syncing endpoints with etcd
k8s.io/kubernetes/cmd/kubeadm/app/util/etcd.NewFromCluster
        cmd/kubeadm/app/util/etcd/etcd.go:120
k8s.io/kubernetes/cmd/kubeadm/app/phases/etcd.CheckLocalEtcdClusterStatus
        cmd/kubeadm/app/phases/etcd/local.go:75
k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/join.runCheckEtcdPhase
        cmd/kubeadm/app/cmd/phases/join/checketcd.go:69
k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/workflow.(*Runner).Run.func1
        cmd/kubeadm/app/cmd/phases/workflow/runner.go:234
k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/workflow.(*Runner).visitAll
        cmd/kubeadm/app/cmd/phases/workflow/runner.go:421
k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/workflow.(*Runner).Run
        cmd/kubeadm/app/cmd/phases/workflow/runner.go:207
k8s.io/kubernetes/cmd/kubeadm/app/cmd.newCmdJoin.func1
        cmd/kubeadm/app/cmd/join.go:178
k8s.io/kubernetes/vendor/github.com/spf13/cobra.(*Command).execute
        vendor/github.com/spf13/cobra/command.go:856
k8s.io/kubernetes/vendor/github.com/spf13/cobra.(*Command).ExecuteC
        vendor/github.com/spf13/cobra/command.go:974
k8s.io/kubernetes/vendor/github.com/spf13/cobra.(*Command).Execute
        vendor/github.com/spf13/cobra/command.go:902
k8s.io/kubernetes/cmd/kubeadm/app.Run
        cmd/kubeadm/app/kubeadm.go:50
main.main
        cmd/kubeadm/kubeadm.go:25
runtime.main
        /usr/local/go/src/runtime/proc.go:250
runtime.goexit
        /usr/local/go/src/runtime/asm_amd64.s:1571
error execution phase check-etcd
k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/workflow.(*Runner).Run.func1
        cmd/kubeadm/app/cmd/phases/workflow/runner.go:235
k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/workflow.(*Runner).visitAll
        cmd/kubeadm/app/cmd/phases/workflow/runner.go:421
k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/workflow.(*Runner).Run
        cmd/kubeadm/app/cmd/phases/workflow/runner.go:207
k8s.io/kubernetes/cmd/kubeadm/app/cmd.newCmdJoin.func1
        cmd/kubeadm/app/cmd/join.go:178
k8s.io/kubernetes/vendor/github.com/spf13/cobra.(*Command).execute
        vendor/github.com/spf13/cobra/command.go:856
k8s.io/kubernetes/vendor/github.com/spf13/cobra.(*Command).ExecuteC
        vendor/github.com/spf13/cobra/command.go:974
k8s.io/kubernetes/vendor/github.com/spf13/cobra.(*Command).Execute
        vendor/github.com/spf13/cobra/command.go:902
k8s.io/kubernetes/cmd/kubeadm/app.Run
        cmd/kubeadm/app/kubeadm.go:50
main.main
        cmd/kubeadm/kubeadm.go:25
runtime.main
        /usr/local/go/src/runtime/proc.go:250
runtime.goexit
        /usr/local/go/src/runtime/asm_amd64.s:1571
vagrant@vm-master2:/tmp$ ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 02:fe:c0:34:c3:ed brd ff:ff:ff:ff:ff:ff
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe40:77e4/64 scope link
       valid_lft forever preferred_lft forever
vagrant@vm-master2:/tmp$ netstat

Command 'netstat' not found, but can be installed with:

apt install net-tools
Please ask your administrator.

vagrant@vm-master2:/tmp$ sudo apt install net-tools
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following NEW packages will be installed:
  net-tools
0 upgraded, 1 newly installed, 0 to remove and 17 not upgraded.
Need to get 196 kB of archives.
After this operation, 864 kB of additional disk space will be used.
Get:1 http://archive.ubuntu.com/ubuntu focal/main amd64 net-tools amd64 1.60+git20180626.aebd88e-1ubuntu1 [196 kB]
Fetched 196 kB in 2s (111 kB/s)
Selecting previously unselected package net-tools.
(Reading database ... 63656 files and directories currently installed.)
Preparing to unpack .../net-tools_1.60+git20180626.aebd88e-1ubuntu1_amd64.deb ...
Unpacking net-tools (1.60+git20180626.aebd88e-1ubuntu1) ...
Setting up net-tools (1.60+git20180626.aebd88e-1ubuntu1) ...
Processing triggers for man-db (2.9.1-1) ...
vagrant@vm-master2:/tmp$ netstat -tunlp
(Not all processes could be identified, non-owned process info
 will not be shown, you would have to be root to see it all.)
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 127.0.0.1:46165         0.0.0.0:*               LISTEN      -
tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN      -
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      -
tcp6       0      0 :::22                   :::*                    LISTEN      -
udp        0      0 127.0.0.53:53           0.0.0.0:*                           -
udp        0      0 10.0.2.15:68            0.0.0.0:*                           -
vagrant@vm-master2:/tmp$ telnet 192.168.56.11 2379
Trying 192.168.56.11...
telnet: Unable to connect to remote host: Connection refused
vagrant@vm-master2:/tmp$ ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 02:fe:c0:34:c3:ed brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic enp0s3
       valid_lft 76511sec preferred_lft 76511sec
    inet6 fe80::fe:c0ff:fe34:c3ed/64 scope link
       valid_lft forever preferred_lft forever
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:40:77:e4 brd ff:ff:ff:ff:ff:ff
    inet 192.168.56.12/24 brd 192.168.56.255 scope global enp0s8
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe40:77e4/64 scope link
       valid_lft forever preferred_lft forever
vagrant@vm-master2:/tmp$ telnet 192.168.56.11 2379
Trying 192.168.56.11...
telnet: Unable to connect to remote host: Connection refused

```

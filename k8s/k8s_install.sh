 swapoff -a
sed -i '/ swap / s/^(.*)$/#1/g' /etc/fstab
systemctl disable firewalld
systemctl stop firewalld
sed -ri 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
setenforce 0
timedatectl set-timezone Asia/Shanghai

###添加网桥过滤及内核转发配置文件
cat <<EOF >/etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
vm.swappiness=0
EOF 
 
sysctl -p /etc/sysctl.d/k8s.conf 

modprobe br_netfilter

lsmod | grep br_netfilter
yum -y install ipset ipvsadm
 
cat > /etc/sysconfig/modules/ipvs.module <<EOF
modprobe -- ip_vs
modprobe -- ip_vs_sh
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- nf_conntrack
EOF


ssh-keygen -t rsa

ssh-copy-id -i ~/.ssh/id_rsa.pub  root@192.168.107.131


chmod 755 /etc/sysconfig/modules/ipvs.module &&  /etc/sysconfig/modules/ipvs.module

sudo yum install -y yum-utils
 sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
 
 sudo yum install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
sudo systemctl start docker

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF
###注释cri
vim /etc/containerd/config.toml

service docker restart
systemctl restart containerd
net.ipv4.ip_local_reserved_ports = 30000-32767
vm.max_map_count = 262144
vm.swappiness = 1
fs.inotify.max_user_instances = 524288
kernel.pid_max = 65535



net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-arptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_local_reserved_ports = 30000-32767
vm.max_map_count = 262144
vm.swappiness = 1
fs.inotify.max_user_instances = 524288
kernel.pid_max = 65535


mkdir /etc/docker
#添加一下内容
{
"graph": "/data/docker",
"exec-opts": ["native.cgroupdriver=systemd"]
}

# 将 SELinux 设置为 permissive 模式（相当于将其禁用）
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

sudo systemctl enable --now kubelet








ubeadm config images pull




apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: kubernetes-dashboard
spec:
  rules:
  - host: lb.kubesphere.local
    http:
      paths:
      - path: /
        backend:
          serviceName: kubernetes-dashboard
          servicePort: 80
EOF






问题
1.  [root@localhost ~]# kubectl get nodes
The connection to the server localhost:8080 was refused - did you specify the right host or port?
 出现这个问题的原因是kubectl命令需要使用kubernetes-admin来运行，解决方法如下，将主节点中的【/etc/kubernetes/admin.conf】文件拷贝到从节点相同目录下，然后配置环境变量：
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bash_profile
立即生效
source ~/.bash_profile

2.
/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
kubectl -n kubernetes-dashboard delete serviceaccount admin-user
kubectl -n kubernetes-dashboard delete clusterrolebinding admin-user
kubectl edit deployment/kubernetes-dashboard --namespace=kube-system
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')

kubectl -n kubesphere-system get pod  -o yaml ks-apiserver-6cd95fb98f-kgcb2

https://bbotte.github.io/virtualization/kubernetes-dashboard-login-method.html


问题1.[root@ceph-2 ~]# kubeadm join 192.168.12.129:6443 --token abcdef.0123456789abcdef --discovery-token-ca-cert-hash sha256:41886d178a3b6d1ab937fe2a9ba04a200897ba04a5dee43f6a39670ae30c0327
[preflight] Running pre-flight checks
error execution phase preflight: [preflight] Some fatal errors occurred:
  [ERROR FileContent--proc-sys-net-bridge-bridge-nf-call-iptables]: /proc/sys/net/bridge/bridge-nf-call-iptables does not exist
[preflight] If you know what you are doing, you can make a check non-fatal with --ignore-preflight-errors=...

解决办法：modprobe br_netfilter  自动加载桥接模块


问题2.[root@ceph-1 ~]# kubeadm config images pull  --config=./init-config.yaml
failed to pull image "registry.k8s.io/kube-apiserver:v1.25.0": output: E1219 18:55:28.423628   67639 remote_impc error: code = Unimplemented desc = unknown service runtime.v1alpha2.ImageService" image="registry.k8s.io/ku
time="2022-12-19T18:55:28+08:00" level=fatal msg="pulling image: rpc error: code = Unimplemented desc = unknow
, error: exit status 1
To see the stack trace of this error execute with --v=5 or higher

解决方法：
[root@ceph-1 ~]# cat > /etc/containerd/config.toml <<EOF
> [plugins."io.containerd.grpc.v1.cri"]
>   systemd_cgroup = true
> EOF
systemctl restart containerd


问题3.[root@master1 ~]# kubectl get pods
Unable to connect to the server: x509: certificate signed by unknown authority (possibly because of "crypto/rsa: verification error" while trying to verify candidate authority certificate "kubernetes")
解决方法：
To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf


问题4.[root@node1 ~]# kubeadm join 192.168.12.129:6443 --token abcdef.0123456789abcdef \
> --discovery-token-ca-cert-hash sha256:5f2bf1559744ca065b15bd2cb39b7b2f86d88f27b25ee8cf7aeccf3b0cc290eb
[preflight] Running pre-flight checks
error execution phase preflight: [preflight] Some fatal errors occurred:
  [ERROR CRI]: container runtime is not running: output: time="2022-12-20T20:32:24+08:00" level=fatal msg="unable to determine runtime API version: rpc error: code = DeadlineExceeded desc = context deadline exceeded"
, error: exit status 1
  [ERROR FileContent--proc-sys-net-bridge-bridge-nf-call-iptables]: /proc/sys/net/bridge/bridge-nf-call-iptables does not exist
[preflight] If you know what you are doing, you can make a check non-fatal with --ignore-preflight-errors=...
To see the stack trace of this error execute with --v=5 or higher
解决办法：
是因为cri没有启动导致的，根据自己使用的cri是否是docker，containerd选择启动
[root@node1 ~]# systemctl start docker
[root@node1 ~]# kubeadm join 192.168.12.129:6443 --token abcdef.0123456789abcdef --discovery-token-ca-cert-hash sha256:5f2bf1559744ca065b15bd2cb39b7b2f86d88f27b25ee8cf7aeccf3b0cc290eb
[preflight] Running pre-flight checks
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap..
This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.
Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
问题5.集群的cri(容器运行时）要是没有进行配置正确，会导致集群组件一直pending，比如：
Warning  FailedCreatePodSandBox  17m (x3 over 17m)     kubelet            (combined from similar events): Failed to create pod sandbox: rpc error: code = Unknown desc = failed to setup network for sandbox "b3d13c945c16bec3910bf6a021fdcac5c2ab1f0bc04ff0af86026867dd320be9": plugin type="flannel" failed (add): loadFlannelSubnetEnv failed: open /run/flannel/subnet.env: no such file or directory

[root@master1 ~]# kubectl get pods -A
NAMESPACE     NAME                              READY   STATUS    RESTARTS      AGE
kube-system   coredns-565d847f94-vvkbq          0/1     Unknown   0             100m
kube-system   coredns-565d847f94-zfljv          0/1     Unknown   0             100m
kube-system   etcd-master1                      1/1     Running   5 (17m ago)   100m
kube-system   kube-apiserver-master1            1/1     Running   5 (17m ago)   100m
kube-system   kube-controller-manager-master1   1/1     Running   3 (17m ago)   100m
kube-system   kube-proxy-9mtmv                  1/1     Running   0             31m
kube-system   kube-proxy-qvg7t                  1/1     Running   2 (17m ago)   100m
kube-system   kube-scheduler-master1            1/1     Running   6 (17m ago)   100m

安装flannel网络组件后；等待组件启动成功，相应的pod也会运行正常：
[root@master1 ~]# kubectl  get pods -A
NAMESPACE     NAME                              READY   STATUS     RESTARTS      AGE
kube-system   coredns-565d847f94-vvkbq          0/1     Unknown    0             103m
kube-system   coredns-565d847f94-zfljv          0/1     Unknown    0             103m
kube-system   etcd-master1                      1/1     Running    5 (20m ago)   103m
kube-system   kube-apiserver-master1            1/1     Running    5 (20m ago)   103m
kube-system   kube-controller-manager-master1   1/1     Running    3 (20m ago)   103m
kube-system   kube-flannel-ds-j554j             0/1     Init:1/2   0             6s
kube-system   kube-flannel-ds-xlz2q             0/1     Init:0/2   0             6s
kube-system   kube-proxy-9mtmv                  1/1     Running    0             35m
kube-system   kube-proxy-qvg7t                  1/1     Running    2 (20m ago)   103m
kube-system   kube-scheduler-master1            1/1     Running    6 (20m ago)   103m
[root@master1 ~]# kubectl  get pods -A
^[[ANAMESPACE     NAME                              READY   STATUS    RESTARTS      AGE
kube-system   coredns-565d847f94-vvkbq          1/1     Running   1 (69m ago)   104m
kube-system   coredns-565d847f94-zfljv          1/1     Running   1 (69m ago)   104m
kube-system   etcd-master1                      1/1     Running   5 (21m ago)   104m
kube-system   kube-apiserver-master1            1/1     Running   5 (21m ago)   104m
kube-system   kube-controller-manager-master1   1/1     Running   3 (21m ago)   104m
kube-system   kube-flannel-ds-j554j             1/1     Running   0             69s
kube-system   kube-flannel-ds-xlz2q             1/1     Running   0             69s
kube-system   kube-proxy-9mtmv                  1/1     Running   0             36m
kube-system   kube-proxy-qvg7t                  1/1     Running   2 (21m ago)   104m
kube-system   kube-scheduler-master1            1/1     Running   6 (21m ago)   104m
需要注意的是：flannel.yaml的配置network需要和k8s集群启动文件里的subpodtnet的ip范围一直，如下是需要改的flannel。yaml段：
 net-conf.json: |
    {
      "Network": "10.48.0.0/12",
      "Backend": {
        "Type": "vxlan"
      }
    }
[root@master1 ~]# cat /run/flannel/subnet.env 
FLANNEL_NETWORK=10.48.0.0/12
FLANNEL_SUBNET=10.48.0.1/24
FLANNEL_MTU=1450
FLANNEL_IPMASQ=true
https://kubeedge.io/zh/docs/advanced/cri_zh/
问题6.节点join问题
[root@node1 ~]# kubeadm join 192.168.12.129:6443 --token abcdef.0123456789abcdef --discovery-token-ca-cert-hash sha256:5f2bf1559744ca065b15bd2cb39b7b2f86d88f27b25ee8cf7aeccf3b0cc290eb
[preflight] Running pre-flight checks
  [WARNING Swap]: swap is enabled; production deployments should disable swap unless testing the NodeSwap feature gate of the kubelet
error execution phase preflight: [preflight] Some fatal errors occurred:
  [ERROR CRI]: container runtime is not running: output: time="2022-12-20T21:36:19+08:00" level=fatal msg="unable to determine runtime API version: rpc error: code = Unavailable desc = connection error: desc = \"transport: Error while dialing dial unix /var/run/containerd/containerd.sock: connect: no such file or directory\""
, error: exit status 1
  [ERROR FileContent--proc-sys-net-bridge-bridge-nf-call-iptables]: /proc/sys/net/bridge/bridge-nf-call-iptables does not exist
[preflight] If you know what you are doing, you can make a check non-fatal with --ignore-preflight-errors=...
To see the stack trace of this error execute with --v=5 or higher
[root@node1 ~]# systemctl start containerd
[root@node1 ~]# kubeadm join 192.168.12.129:6443 --token abcdef.0123456789abcdef --discovery-token-ca-cert-hash sha256:5f2bf1559744ca065b15bd2cb39b7b2f86d88f27b25ee8cf7aeccf3b0cc290eb
[preflight] Running pre-flight checks
  [WARNING Swap]: swap is enabled; production deployments should disable swap unless testing the NodeSwap feature gate of the kubelet
error execution phase preflight: [preflight] Some fatal errors occurred:
  [ERROR FileContent--proc-sys-net-bridge-bridge-nf-call-iptables]: /proc/sys/net/bridge/bridge-nf-call-iptables does not exist
[preflight] If you know what you are doing, you can make a check non-fatal with --ignore-preflight-errors=...
To see the stack trace of this error execute with --v=5 or higher
[root@node1 ~]# systemctl start docker
[root@node1 ~]# kubeadm join 192.168.12.129:6443 --token abcdef.0123456789abcdef --discovery-token-ca-cert-hash sha256:5f2bf1559744ca065b15bd2cb39b7b2f86d88f27b25ee8cf7aeccf3b0cc290eb
[preflight] Running pre-flight checks
  [WARNING Swap]: swap is enabled; production deployments should disable swap unless testing the NodeSwap feature gate of the kubelet
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
error execution phase kubelet-start: a Node with name "node1" and status "Ready" already exists in the cluster. You must delete the existing Node or change the name of this new joining Node
To see the stack trace of this error execute with --v=5 or higher
[root@node1 ~]# hostnamectl  set-hostname node2

问题6. 服务器异常关闭，etcd数据缺损，导致集群无法启动

问题7.namespace无法正长删除，一直处于terminiting,
[root@master1 ~]# kubectl get ns rook-ceph -o json > rook-ceph.json 导出，
kubectl proxy,
[root@master1 ~]# curl --cacert /root/ca.crt --cert /root/client.crt --key /root/client.key -k -H "Content-Type:application/json" -X PUT --data-binary @rook-ceph.json http://127.0.0.1:8001/api/v1/namespaces/rook-ceph/finalize


cat > /etc/containerd/config.toml <<EOF
 [plugins."io.containerd.grpc.v1.cri"]
   systemd_cgroup = true
 EOF
KubeEdge一个支持边缘计算的开放平台
使用CRI设置不同的container runtime | KubeEdge一个支持边缘计算的开放平台
containerd Docker 18.09 及更高版本自带 containerd ，因此您无需手动安装。如果您没有 containerd ，可以通过运行以下命令进行安装： # Install containerd apt-get update && apt-get install -y cont...

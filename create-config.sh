#!/bin/bash
set +ex
#######################################
# set variables below to create the config files, all files will create at ./config directory
#######################################

# 1.14 shoud set keepalive and haproxy first

export K8SHA_KA_STATE=master

# master keepalived virtual ip address
export K8SHA_VIP=192.168.76.65

# master01 ip address
export K8SHA_IP1=192.168.76.60

# master02 ip address
export K8SHA_IP2=192.168.76.61

# master03 ip address
export K8SHA_IP3=192.168.76.62

# master keepalived virtual ip hostname
export K8SHA_VHOST=m-vip.local

# master01 hostname
export K8SHA_HOST1=m1.local

# master02 hostname
export K8SHA_HOST2=m2.local

# master03 hostname
export K8SHA_HOST3=m3.local

# master01 network interface name
export K8SHA_NETINF1=ens192

# master02 network interface name
export K8SHA_NETINF2=ens192

# master03 network interface name
export K8SHA_NETINF3=ens192

# keepalived auth_pass config
export K8SHA_KEEPALIVED_AUTH=412f7dc3bfed32194d1600c483e10ad1d

# tell calico how to get host ip
# https://docs.projectcalico.org/v2.2/reference/node/configuration#ip-autodetection-methods
export CALICO_REACHE_METHOD="interface=ens192"

# kubernetes CIDR pod subnet
export K8SHA_CIDR=10.76.0.0

##############################
# If you don't know what the script below means. please stop to modify them.
##############################

mkdir -p config/$K8SHA_HOST1/keepalived
mkdir -p config/$K8SHA_HOST2/keepalived
mkdir -p config/$K8SHA_HOST3/keepalived

# create all kubeadm-config.yaml files

sed \
-e "s/K8SHA_HOST1/${K8SHA_HOST1}/g" \
-e "s/K8SHA_HOST2/${K8SHA_HOST2}/g" \
-e "s/K8SHA_HOST3/${K8SHA_HOST3}/g" \
-e "s/K8SHA_VHOST/${K8SHA_VHOST}/g" \
-e "s/K8SHA_IP1/${K8SHA_IP1}/g" \
-e "s/K8SHA_IP2/${K8SHA_IP2}/g" \
-e "s/K8SHA_IP3/${K8SHA_IP3}/g" \
-e "s/K8SHA_VIP/${K8SHA_VIP}/g" \
-e "s/K8SHA_CIDR/${K8SHA_CIDR}/g" \
kubeadm-config.yaml.tpl > kubeadm-config.yaml

echo "create kubeadm-config.yaml files success. kubeadm-config.yaml"

sed \
-e "s/K8SHA_KA_STATE/${K8SHA_KA_STATE}/g" \
-e "s/K8SHA_KA_INTF/${K8SHA_NETINF1}/g" \
-e "s/K8SHA_IPLOCAL/${K8SHA_IP1}/g" \
-e "s/K8SHA_KA_PRIO/102/g" \
-e "s/K8SHA_VIP/${K8SHA_VIP}/g" \
-e "s/K8SHA_KA_AUTH/${K8SHA_KEEPALIVED_AUTH}/g" \
keepalived/keepalived.conf.tpl > config/$K8SHA_HOST1/keepalived/keepalived.conf

sed \
-e "s/K8SHA_KA_STATE/${K8SHA_KA_STATE}/g" \
-e "s/K8SHA_KA_INTF/${K8SHA_NETINF2}/g" \
-e "s/K8SHA_IPLOCAL/${K8SHA_IP2}/g" \
-e "s/K8SHA_KA_PRIO/101/g" \
-e "s/K8SHA_VIP/${K8SHA_VIP}/g" \
-e "s/K8SHA_KA_AUTH/${K8SHA_KEEPALIVED_AUTH}/g" \
keepalived/keepalived.conf.tpl > config/$K8SHA_HOST2/keepalived/keepalived.conf

sed \
-e "s/K8SHA_KA_STATE/${K8SHA_KA_STATE}/g" \
-e "s/K8SHA_KA_INTF/${K8SHA_NETINF3}/g" \
-e "s/K8SHA_IPLOCAL/${K8SHA_IP3}/g" \
-e "s/K8SHA_KA_PRIO/100/g" \
-e "s/K8SHA_VIP/${K8SHA_VIP}/g" \
-e "s/K8SHA_KA_AUTH/${K8SHA_KEEPALIVED_AUTH}/g" \
keepalived/keepalived.conf.tpl > config/$K8SHA_HOST3/keepalived/keepalived.conf

echo "create keepalived files success. config/$K8SHA_HOST1/keepalived/"
echo "create keepalived files success. config/$K8SHA_HOST2/keepalived/"
echo "create keepalived files success. config/$K8SHA_HOST3/keepalived/"

# create calico yaml file
sed \
-e "s/CALICO_REACHE_METHOD/${CALICO_REACHE_METHOD}/g" \
-e "s/K8SHA_CIDR/${K8SHA_CIDR}/g" \
calico/calico.yaml.tpl > calico/calico.yaml


scp -r config/$K8SHA_HOST1/keepalived/* root@$K8SHA_HOST1:/etc/keepalived/
scp -r config/$K8SHA_HOST2/keepalived/* root@$K8SHA_HOST2:/etc/keepalived/
scp -r config/$K8SHA_HOST3/keepalived/* root@$K8SHA_HOST3:/etc/keepalived/

set -ex

#Required
REGISTRY_USER=${1}
REGISTRY_TOKEN=${2}


#Insatall software
sudo yum install -y podman
sudo yum module install -y container-tools


#Login to registry: 
podman login --authfile ~/.docker/config.json -u  $REGISTRY_USER -p $REGISTRY_TOKEN https://registry.ci.openshift.org

#or iptables if being used: 
sudo iptables -A INPUT -p tcp -m multiport --dports 8443,8080,443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

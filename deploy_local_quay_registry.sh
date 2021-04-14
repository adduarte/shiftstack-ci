#Required
REGISTRY_USER=${1}
REGISTRY_TOKEN=${2}


#Insatall software
sudo yum install -y podman
sudo yum module install -y container-tools


#Login to registry: 
sudo podman login --authfile /root/.docker/config.json -u  $REGISTRY_USER -p $REGISTRY_TOKEN https://registry.ci.openshift.org



#Set access from outside host if needed:
# if FirewallD is running
sudo firewall-cmd --permanent --add-port=8443/tcp
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --reload
# or iptables if being used: 
sudo iptables -A INPUT -p tcp -m multiport --dports 8443,8080,443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

# setup Postgress for datastorage


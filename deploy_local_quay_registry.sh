#Required
REDHATIO_USER=${1}
REDHATIO_PASSWD=${2}
REGISTRY_USER=${1}
REGISTRY_TOKEN=${2}


#Insatall software
sudo yum install -y podman
sudo yum module install -y container-tools


#Login to registry: 

sudo podman login --authfile /root/.docker/config.json -u  $REGISTRY_USER -p $REGISTRY_TOKEN https://registry.ci.openshift.org
sudo podman login --authfile /root/.docker/config.json -u $REDHATIO_USER -p $REDHATIO_PASSWD registry.redhat.io


#Set access from outside host if needed:
# if FirewallD is running
sudo firewall-cmd --permanent --add-port=8443/tcp
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --reload
# or iptables if being used: (note the port numbers, if you decide to exapose quay on a different port fix here as well)
sudo iptables -A INPUT -p tcp -m multiport --dports 8443,8080,443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

# deploy Postgress for datastorage 

mkdir -p $QUAY/postgres-quay
setfacl -m u:26:-wx $QUAY/postgres-quay


$ sudo podman run -d --rm --name postgresql-quay \
  -e POSTGRESQL_USER=quayuser \
  -e POSTGRESQL_PASSWORD=quaypass \
  -e POSTGRESQL_DATABASE=quay \
  -e POSTGRESQL_ADMIN_PASSWORD=adminpass \
  -p 5432:5432 \
  -v $QUAY/postgres-quay:/var/lib/pgsql/data:Z \
  registry.redhat.io/rhel8/postgresql-10:1

# Ensure that the Postgres pg_trgm module is installed, as it is required by Quay:

sudo podman exec -it postgresql-quay /bin/bash -c 'echo "CREATE EXTENSION IF NOT EXISTS pg_trgm" | psql -d quay -U postgres'


#Setup Redis
#Use podman to run the Redis container, specifying the port and password. with the exmaple below you would use
# "strongpassword" as the redi password when configuring quay.

sudo podman run -d --rm --name redis   -p 6379:6379 -e REDIS_PASSWORD=strongpassword registry.redhat.io/rhel8/redis-5:1

# Configure Red Hat Quay. Set OUTSIDEPORT accordingly. This is the port wich will be used to access quay_config
OUTSIDEPORT=8181
sudo podman run --rm -it --name quay_config -p ${OUTSIDEPORT}:8080 registry.redhat.io/quay/quay-rhel8:v3.4.3 config secret

#Continue on the web config of quay. use OUTSIDEPORT to access quay_config. 
echo "continue with instructions at https://access.redhat.com/documentation/en-us/red_hat_quay/3.4/html/deploy_red_hat_quay_for_proof-of-concept_non-production_purposes/getting_started_with_red_hat_quay"

echo "Once you have succesfully configured quay, uploaded the configuration bundle (quay-config.tar.gz) to this host, and stopped the quay_config, press enter to continue"
read -p "Press [Enter] key to continue, or ^C to quit"


#Deploy Red Hat Quay

#Prepare config folder
mkdir $QUAY/config
tar -xzf quay-config.tar.gz -C $QUAY/config

# Prepare local storage for image data
mkdir $QUAY/storage
setfacl -m u:1001:-wx $QUAY/storage

#Deploy quay with the desired ports
EXTERNAL_PORT=8181
INTERNAL_PORT=8181

sudo podman run -d --rm -p ${EXTERNAL_PORT}:${INTERNAL_PORT}  \
   --name=quay \
   -v $QUAY/config:/conf/stack:Z \
   -v $QUAY/storage:/datastorage:Z \
   registry.redhat.io/quay/quay-rhel8:v3.4.3
   
 # add credentials to auth file
 sudo podman login --authfile /root/.docker/config.json  $(hostname):${EXTERNAL_PORT}

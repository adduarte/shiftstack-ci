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
sudo podman login --authfile /root/.docker/config.json -u $REDHATIO -p $REDHATIO_PASSWD registry.redhat.io


#Set access from outside host if needed:
# if FirewallD is running
sudo firewall-cmd --permanent --add-port=8443/tcp
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --reload
# or iptables if being used: 
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
#Use podman to run the Redis container, specifying the port and password:

sudo podman run -d --rm --name redis   -p 6379:6379 -e REDIS_PASSWORD=strongpassword registry.redhat.io/rhel8/redis-5:1

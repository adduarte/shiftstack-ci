eval "$(go env)"

export OS_CLOUD=""
export CLUSTER_NAME=""

export OPENSHIFT_INSTALL_DATA="$GOPATH/src/github.com/openshift/installer/data/data"
export OPENSTACK_REGION=moc-kzn
export OPENSTACK_IMAGE=rhcos
export OPENSTACK_FLAVOR=m1.medium
export BASE_DOMAIN=shiftstack.com
export OPENSTACK_EXTERNAL_NETWORK=external
export PULL_SECRET='{"auths": { "quay.io": { "auth": "Y29yZW9zK3RlYzJfaWZidWdsa2VndmF0aXJyemlqZGMybnJ5ZzpWRVM0SVA0TjdSTjNROUUwMFA1Rk9NMjdSQUZNM1lIRjRYSzQ2UlJBTTFZQVdZWTdLOUFIQlM1OVBQVjhEVlla", "email": "" }}}'
export SSH_PUB_KEY="`cat $HOME/.ssh/id_rsa.pub`"

export API_ADDRESS="api.${CLUSTER_NAME}.${BASE_DOMAIN}"
export CONSOLE_ADDRESS="console-openshift-console.apps.${CLUSTER_NAME}.${BASE_DOMAIN}"
export AUTH_ADDRESS="openshift-authentication-openshift-authentication.apps.${CLUSTER_NAME}.${BASE_DOMAIN}"

# Not used by the installer.  Used by ssh.
export SSH_PRIV_KEY="$HOME/.ssh/id_rsa"

#!/bin/sh
## when the provider does not support cloud-init provisioning
## e.g. ovh dedicated servers, vps

set -e

CLOUD_INIT_TMPL="https://raw.githubusercontent.com/cloudcall-fr/cloud-init-ansible/1.0.0/cloud-init-ansible-roles.yml.tmpl"

FILE=.env
if [ -f "$FILE" ]; then
    . .env
fi

mkdir -p /var/lib/cloud/seed/nocloud-net

meta_data=$(cloud-init query ds.meta_data) 
for i in $(seq 10)
do
  meta_data=$(echo "$meta_data" | sed -r 's/^( +"[a-zA-Z0-9-]+)_(\w+": )/\1-\2/')
done
echo "$meta_data" > /var/lib/cloud/seed/nocloud-net/meta-data

cp /var/lib/cloud/instance/vendor-data.txt /var/lib/cloud/seed/nocloud-net/vendor-data
curl -sfL $CLOUD_INIT_TMPL | envsubst > /var/lib/cloud/seed/nocloud-net/user-data

cloud-init clean
cloud-init init --local
cloud-init init
cloud-init modules --mode config
cloud-init modules --mode final
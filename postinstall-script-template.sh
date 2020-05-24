#!/bin/sh
## when the provider does not support cloud-init provisioning
## e.g. ovh dedicated servers, vps

set -e

CLOUD_INIT_TMPL="https://raw.githubusercontent.com/cloudcall-fr/cloud-init-ansible/v1.1.0/cloud-init-ansible-roles.yml.tmpl"

set +a
FILE=.env
if [ -f "$FILE" ]; then
    . .env
fi
set -a

mkdir -p /var/lib/cloud/seed/nocloud-net

meta_data=$(cloud-init query ds.meta_data) 
for i in $(seq 10)
do
  meta_data=$(echo "$meta_data" | sed -r 's/^( +"[a-zA-Z0-9-]+)_(\w+": )/\1-\2/')
done
echo "$meta_data" > /var/lib/cloud/seed/nocloud-net/meta-data

cp /var/lib/cloud/instance/vendor-data.txt /var/lib/cloud/seed/nocloud-net/vendor-data
echo "datasource_list: [ NoCloud, None ]" > /var/run/cloud-init/cloud.cfg
echo "datasource_list: [ NoCloud, None ]" > /etc/cloud/cloud.cfg.d/99_nocloud.cfg
rm -rf /dev/sr0 >/dev/null 2>&1
curl -sfL $CLOUD_INIT_TMPL | envsubst > /var/lib/cloud/seed/nocloud-net/user-data

cloud-init clean
cloud-init init --local
cloud-init init
cloud-init modules --mode config
cloud-init modules --mode final

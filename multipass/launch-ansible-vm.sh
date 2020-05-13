#!/bin/sh

FILE=../.env
if [ -f "$FILE" ]; then
    source ../.env
else 
    echo "Please copy ../.env.template to ../.env, then update .env"
    exit 0
fi

envsubst < ../cloud-init-ansible-roles.yml.tmpl | multipass launch --name k3s-vm --mem 4G --disk 40G --cpus 2 $multipass_distro_version --cloud-init -

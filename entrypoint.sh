#!/usr/local/bin/dumb-init /usr/sbin/init /bin/bash

set -e
source /opt/omero/server/venv3/bin/activate

cd /opt/setup/

ansible-galaxy install -p /opt/setup/roles -r requirements.yml \
    && dnf -y clean all \
    && rm -fr /var/cache

ansible-playbook playbook.yml -e 'ansible_python_interpreter=/usr/bin/python3' \
    -e omero_server_release=$OMERO_VERSION \
    -e omero_server_omego_additional_args="$OMEGO_ADDITIONAL_ARGS" \
    && dnf -y clean all \
    && rm -fr /var/cache

for f in /startup/*; do
    if [ -f "$f" -a -x "$f" ]; then
        echo "Running $f $@"
        "$f" "$@"
    fi
done

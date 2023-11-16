FROM eniocarboni/docker-rockylinux-systemd:9

LABEL maintainer="ome-devel@lists.openmicroscopy.org.uk"

RUN dnf -y install epel-release
RUN dnf install -y glibc-langpack-en
ENV LANG en_US.utf-8


RUN mkdir /opt/setup
WORKDIR /opt/setup
ADD playbook.yml requirements.yml /opt/setup/

RUN dnf -y install ansible sudo ca-certificates

RUN ansible-galaxy install -p /opt/setup/roles -r requirements.yml \
    && dnf -y clean all \
    && rm -fr /var/cache

ARG OMERO_VERSION=5.6.9
ARG OMEGO_ADDITIONAL_ARGS=
ENV OMERODIR=/opt/omero/server/OMERO.server/

RUN ansible-playbook playbook.yml -e 'ansible_python_interpreter=/usr/bin/python3' \
    -e omero_server_release=$OMERO_VERSION \
    -e omero_server_omego_additional_args="$OMEGO_ADDITIONAL_ARGS" \
    && dnf -y clean all \
    && rm -fr /var/cache

RUN curl -L -o /usr/local/bin/dumb-init \
    https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64 && \
    chmod +x /usr/local/bin/dumb-init
ADD entrypoint.sh /usr/local/bin/
ADD 50-config.py 60-database.sh 99-run.sh /startup/

USER omero-server
EXPOSE 4063 4064
VOLUME ["/OMERO", "/opt/omero/server/OMERO.server/var"]

CMD ["/usr/local/bin/entrypoint.sh"]

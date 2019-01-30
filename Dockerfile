FROM stakater/base-centos:7

LABEL name="PostgresDB Connection Cleaner" \
      maintainer="Stakater <stakater@aurorasolutions.io>" \
      vendor="Stakater" \
      summary="Cleans idle connections to postgres databases"

USER root

RUN yum install -y https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm && \
    yum update -y

RUN yum install -y  postgresql96-9.6.1

ENV DB_NAMES ""
ENV DB_USER ""
ENV DB_PASSWORD ""
ENV DB_HOST ""
ENV DB_PORT ""
ENV IDLE_TIMEOUT_INTERVAL_MINUTES "15"

RUN mkdir -p /scripts
ADD scripts/ /scripts/

RUN chown -R 10001 /scripts && chmod a+x /scripts/*.sh

# Again using non-root user i.e. stakater as set in base image
USER 10001

CMD ["/bin/bash", "-c", "/scripts/clean-connections.sh"]
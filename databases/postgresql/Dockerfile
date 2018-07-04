FROM alpine:3.6 AS builder
ARG ODMDOCKERDIR
COPY $ODMDOCKERDIR/databases/postgresql/script/rundb.sh /usr/local/bin
RUN chmod a+x /usr/local/bin/rundb.sh
RUN mkdir /tmp/pgdata/
ADD $ODMDOCKERDIR/databases/postgresql/data.tar.gz /upload


FROM centos/postgresql-96-centos7:9.6

LABEL maintainer="Rachel ORTI <rachel.orti@fr.ibm.com>, ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com"
MAINTAINER "Rachel ORTI <rachel.orti@fr.ibm.com>, ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com"

ARG PGDATA
ARG POSTGRES_DB
ARG POSTGRES_USER
ARG POSTGRES_PASSWORD
ENV POSTGRESQL_DATABASE $POSTGRES_DB
ENV POSTGRESQL_USER $POSTGRES_USER
ENV POSTGRESQL_PASSWORD $POSTGRES_PASSWORD

USER 0
RUN ln -s /var/lib/pgsql/data $PGDATA
RUN ln -s /opt/rh/rh-postgresql96/root/usr/bin/psql /usr/local/bin/psql
RUN ln -s /opt/rh/rh-postgresql96/root/usr/lib64/libpq.so.rh-postgresql96-5 /usr/lib64/libpq.so.rh-postgresql96-5
# postgres user
USER 26

COPY --from=builder /usr/local/bin/rundb.sh  /usr/local/bin/
COPY --from=builder --chown=postgres:nobody /upload /upload
COPY --from=builder --chown=postgres:nobody /tmp/pgdata/ $PGDATA/

ENTRYPOINT ["/usr/local/bin/rundb.sh"]
CMD ["run-postgresql"]

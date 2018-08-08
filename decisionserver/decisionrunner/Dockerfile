FROM maven:3.5.2-jdk-8-alpine AS builder
ARG ODMDOCKERDIR
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV SCRIPT /script
ENV APPS /config/apps
ENV THIRDPARTY /thirdpartylib
COPY $ODMDOCKERDIR/welcomepage /welcomepage
COPY $ODMDOCKERDIR/decisionserver/decisionrunner/script $SCRIPT
COPY $ODMDOCKERDIR/common/script $SCRIPT
COPY $ODMDOCKERDIR/common/drivers /config/resources
COPY $ODMDOCKERDIR/common/features $SCRIPT
# Use production liberty if needed
COPY $ODMDOCKERDIR/resources/* /wlp-embeddable/
RUN chmod a+x $SCRIPT/fixWLPForProduction.sh && sync && $SCRIPT/fixWLPForProduction.sh

# Install missing require package in the alpine builder image
RUN apk add --no-cache bash perl ca-certificates wget
# Build welcome page
RUN cd /welcomepage; mvn -B clean install | grep -v 'Download.*' && mkdir -p $APPS
# Decision Runner
COPY ./executionserver/applicationservers/WLP855/DecisionRunner.war $APPS
# Fix for WLP 18.0.0.2
RUN mkdir $THIRDPARTY
COPY ./executionserver/lib/jaxws $THIRDPARTY
RUN ls $THIRDPARTY
# End Fix
RUN chmod -R a+x $SCRIPT && \
    sync && \
    if [ ! -f /config/resources/postgres* ]; then $SCRIPT/installPostgres.sh; fi

RUN $SCRIPT/extractApp.sh DecisionRunner.war

RUN $SCRIPT/changeParamValue.sh ForceDatabaseTableCreation false true $APPS/DecisionRunner.war/WEB-INF/web.xml
RUN $SCRIPT/loadFeatures.sh $SCRIPT

FROM websphere-liberty/centos
ARG ODMDOCKERDIR
ARG ODMVERSION
LABEL maintainer="ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>"
LABEL ProductID="xxxxxxxxxxxxxxxxx"
LABEL ProductName="IBM Operational Decision Manager"
LABEL ProductVersion=$ODMVERSION
MAINTAINER ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>

ENV APP_NAME DecisionRunner
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV CONNECTION_POOL_SIZE 60
ENV SCRIPT /script
ENV APPS /config/apps

COPY --chown=1000080000:nobody $ODMDOCKERDIR/decisionserver/config /config
COPY --chown=1000080000:nobody $ODMDOCKERDIR/decisionserver/decisionrunner/config /config
COPY --chown=1000080000:nobody $ODMDOCKERDIR/common/config /config
COPY --chown=1000080000:nobody $ODMDOCKERDIR/common/security/ltpa.keys /config/resources/security/ltpa.keys
COPY --chown=1000080000:nobody $ODMDOCKERDIR/common/security/keystore.jks /config/security/keystore.jks
COPY --chown=1000080000:nobody $ODMDOCKERDIR/common/security/truststore.jks /config/security/truststore.jks

COPY --chown=1000080000:nobody $ODMDOCKERDIR/common/drivers /config/resources

# Welcome page
COPY --from=builder --chown=1000080000:nobody /welcomepage/target/welcomepage.war $APPS
COPY --from=builder --chown=1000080000:nobody $APPS $APPS
COPY --from=builder /config/resources/postgres*  /config/resources
COPY --from=builder $SCRIPT $SCRIPT
COPY --from=builder /wlp-embeddable/wlp  /opt/ibm/wlp

# TODO fixme USER 0
USER 0
RUN yum install -y perl
# used by /script/updateDRConfigurations.sh
USER 1000080000

EXPOSE 9080 9443
ENTRYPOINT ["/opt/ibm/docker/docker-server"]
CMD ["/script/rundr.sh"]

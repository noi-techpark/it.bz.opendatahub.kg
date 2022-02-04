FROM atomgraph/linkeddatahub:75ec908974d81e636646fdc715d28e7f7bc73c7e

ARG SAXON_VERSION=9.9.1-2

ARG BASE_URI=
ARG OWNER_GIVEN_NAME=
ARG OWNER_FAMILY_NAME=
ARG OWNER_ORG_UNIT=
ARG OWNER_ORGANIZATION=
ARG OWNER_LOCALITY=
ARG OWNER_STATE_OR_PROVINCE=
ARG OWNER_COUNTRY_NAME=
ARG OWNER_CERT_PASSWORD=
ARG SECRETARY_CERT_PASSWORD=

USER root

RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get update --allow-releaseinfo-change && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/* && \
    npm install saxon-js && \
    npm install xslt3

USER ldh

COPY --chown=ldh:ldh config/dev.log4j.properties /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/log4j.properties
COPY --chown=ldh:ldh files/prefix-mapping.ttl /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/prefix-mapping.ttl
COPY --chown=ldh:ldh files/geosparql.rdf /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/it/bz/opendatahub/kg/geosparql.rdf
COPY --chown=ldh:ldh config/system-varnish.trig /var/linkeddatahub/datasets/system.trig
COPY --chown=ldh:ldh datasets/admin.trig /var/linkeddatahub/datasets/admin.trig
COPY --chown=ldh:ldh datasets/end-user.trig /var/linkeddatahub/datasets/end-user.trig

WORKDIR $CATALINA_HOME/webapps/ROOT/static

COPY --chown=ldh:ldh files/layout.xsl it/bz/opendatahub/kg/xsl/layout.xsl
COPY --chown=ldh:ldh files/client.xsl it/bz/opendatahub/kg/xsl/client.xsl
COPY --chown=ldh:ldh files/bootstrap.css it/bz/opendatahub/kg/css/bootstrap.css
COPY --chown=ldh:ldh files/bootstrap-responsive.css it/bz/opendatahub/kg/css/bootstrap-responsive.css
COPY --chown=ldh:ldh files/WKTMap.js it/bz/opendatahub/kg/js/WKTMap.js
COPY --chown=ldh:ldh files/favicon.ico /usr/local/tomcat/webapps/ROOT/static/favicon.ico

RUN curl https://repo1.maven.org/maven2/net/sf/saxon/Saxon-HE/${SAXON_VERSION}/Saxon-HE-${SAXON_VERSION}.jar -O && \
    cat com/atomgraph/linkeddatahub/xsl/client.xsl | grep 'xsl:import' | cut -d '"' -f 2 | xargs -n 1 -I{} java -cp Saxon-HE-${SAXON_VERSION}.jar net.sf.saxon.Query -qs:"." -s:com/atomgraph/linkeddatahub/xsl/{} -o:com/atomgraph/linkeddatahub/xsl/{} && \
    cat com/atomgraph/linkeddatahub/xsl/client.xsl | grep 'xsl:include' | cut -d '"' -f 2 | xargs -n 1 -I{} java -cp Saxon-HE-${SAXON_VERSION}.jar net.sf.saxon.Query -qs:"." -s:com/atomgraph/linkeddatahub/xsl/{} -o:com/atomgraph/linkeddatahub/xsl/{} && \
    java -cp Saxon-HE-${SAXON_VERSION}.jar net.sf.saxon.Query -qs:"." -s:com/atomgraph/linkeddatahub/xsl/client.xsl -o:com/atomgraph/linkeddatahub/xsl/client.xsl && \
    npx xslt3 -t -xsl:it/bz/opendatahub/kg/xsl/client.xsl -export:it/bz/opendatahub/kg/xsl/client.xsl.sef.json -nogo -ns:##html5 && \
    rm Saxon-HE-${SAXON_VERSION}.jar && \
    setfacl -Rm user:ldh:rwx it/bz/opendatahub/kg/xsl

WORKDIR $CATALINA_HOME

COPY --chown=ldh:ldh setup.sh setup.sh

RUN ./setup.sh \
    /var/linkeddatahub/ssl \
    "$BASE_URI" \
    "$OWNER_GIVEN_NAME" \
    "$OWNER_FAMILY_NAME" \
    "$OWNER_ORG_UNIT" \
    "$OWNER_ORGANIZATION" \
    "$OWNER_LOCALITY" \
    "$OWNER_STATE_OR_PROVINCE" \
    "$OWNER_COUNTRY_NAME" \
    "$OWNER_CERT_PASSWORD" \
    "$SECRETARY_CERT_PASSWORD" \
    3650

ENTRYPOINT ["/bin/sh", "entrypoint.sh"]
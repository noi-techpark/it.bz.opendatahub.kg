FROM atomgraph/linkeddatahub:c4cf6a4b848871ebc2b0b72d28ea23adda43f087

USER root

ARG SAXON_VERSION=9.9.1-2
ARG ENV_FILE=.env
#ARG CERT_PASSWORD=

RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get update --allow-releaseinfo-change && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/* && \
    npm install saxon-js && \
    npm install xslt3

USER ldh

WORKDIR $CATALINA_HOME/webapps/ROOT/static

COPY --chown=ldh:ldh infrastructure/docker/linkeddatahub/files/layout.xsl it/bz/opendatahub/kg/xsl/layout.xsl
COPY --chown=ldh:ldh infrastructure/docker/linkeddatahub/files/client.xsl it/bz/opendatahub/kg/xsl/client.xsl
COPY --chown=ldh:ldh infrastructure/docker/linkeddatahub/files/bootstrap.css it/bz/opendatahub/kg/css/bootstrap.css
COPY --chown=ldh:ldh infrastructure/docker/linkeddatahub/files/WKTMap.js it/bz/opendatahub/kg/js/WKTMap.js
COPY --chown=ldh:ldh infrastructure/docker/linkeddatahub/dev.log4j.properties /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/log4j.properties
COPY --chown=ldh:ldh infrastructure/docker/linkeddatahub/system-varnish.trig /var/linkeddatahub/datasets/system.trig
COPY --chown=ldh:ldh infrastructure/docker/linkeddatahub/datasets/admin.trig /var/linkeddatahub/datasets/admin.trig
COPY --chown=ldh:ldh infrastructure/docker/linkeddatahub/datasets/end-user.trig /var/linkeddatahub/datasets/end-user.trig

RUN curl https://repo1.maven.org/maven2/net/sf/saxon/Saxon-HE/${SAXON_VERSION}/Saxon-HE-${SAXON_VERSION}.jar -O && \
    cat com/atomgraph/linkeddatahub/xsl/client.xsl | grep 'xsl:import' | cut -d '"' -f 2 | xargs -n 1 -I{} java -cp Saxon-HE-${SAXON_VERSION}.jar net.sf.saxon.Query -qs:"." -s:com/atomgraph/linkeddatahub/xsl/{} -o:com/atomgraph/linkeddatahub/xsl/{} && \
    java -cp Saxon-HE-${SAXON_VERSION}.jar net.sf.saxon.Query -qs:"." -s:com/atomgraph/linkeddatahub/xsl/client.xsl -o:com/atomgraph/linkeddatahub/xsl/client.xsl && \
    npx xslt3 -t -xsl:it/bz/opendatahub/kg/xsl/client.xsl -export:it/bz/opendatahub/kg/xsl/client.xsl.sef.json -nogo -ns:##html5 && \
    rm Saxon-HE-${SAXON_VERSION}.jar && \
    setfacl -Rm user:ldh:rwx it/bz/opendatahub/kg/xsl

WORKDIR $CATALINA_HOME

COPY --chown=ldh:ldh infrastructure/docker/linkeddatahub/setup.sh setup.sh
COPY --chown=ldh:ldh "$ENV_FILE" .env

RUN ./setup.sh .env /var/linkeddatahub/ssl OpenDataHub OpenDataHub 3650

ENTRYPOINT ["/bin/sh", "entrypoint.sh"]
FROM atomgraph/linkeddatahub:95daf8aea14d0c202f85b178f136008178eb2036

USER root

ARG SAXON_VERSION=9.9.1-2

RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get update --allow-releaseinfo-change && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/* && \
    npm install saxon-js && \
    npm install xslt3

USER ldh

WORKDIR $CATALINA_HOME/webapps/ROOT/static

COPY --chown=ldh:ldh files/client.xsl org/example/noi/xsl/client.xsl

RUN curl https://repo1.maven.org/maven2/net/sf/saxon/Saxon-HE/${SAXON_VERSION}/Saxon-HE-${SAXON_VERSION}.jar -O && \
    cat com/atomgraph/linkeddatahub/xsl/client.xsl | grep 'xsl:import' | cut -d '"' -f 2 | xargs -n 1 -I{} java -cp Saxon-HE-${SAXON_VERSION}.jar net.sf.saxon.Query -qs:"." -s:com/atomgraph/linkeddatahub/xsl/{} -o:com/atomgraph/linkeddatahub/xsl/{} && \
    java -cp Saxon-HE-${SAXON_VERSION}.jar net.sf.saxon.Query -qs:"." -s:com/atomgraph/linkeddatahub/xsl/client.xsl -o:com/atomgraph/linkeddatahub/xsl/client.xsl && \
    npx xslt3 -t -xsl:org/example/noi/xsl/client.xsl -export:org/example/noi/xsl/client.xsl.sef.json -nogo -ns:##html5 && \
    rm Saxon-HE-${SAXON_VERSION}.jar && \
    setfacl -Rm user:ldh:rwx org/example/noi/xsl

WORKDIR $CATALINA_HOME

ENTRYPOINT ["/bin/sh", "entrypoint.sh"]
FROM atomgraph/nginx:d329ba2207773d849c41894408fc073dbe27e3b8

COPY config/nginx.http.conf.template /etc/nginx/nginx.http.conf.template

COPY config/nginx.https.conf.template /etc/nginx/nginx.https.conf.template

ENV CONF_TEMPLATE=/etc/nginx/nginx.http.conf.template

CMD ["/bin/bash", "-c", "envsubst '$HTTPS_PORT $UPSTREAM_SERVER $UPSTREAM_HTTP_PORT $SERVER_NAME $SERVER_HTTPS_PORT $SERVER_HTTP_PORT $SERVER_CERT_FILE $SERVER_KEY_FILE $MAX_BODY_SIZE' < \"$CONF_TEMPLATE\" > /etc/nginx/nginx.conf && nginx -g 'daemon off;'"]
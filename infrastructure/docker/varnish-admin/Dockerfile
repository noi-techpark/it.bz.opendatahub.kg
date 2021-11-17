FROM atomgraph/varnish:446f28a3cfedc276b2c27a971455659be98d7351

COPY config/varnish.vcl.template /etc/varnish/default.vcl.template

ENTRYPOINT [ "/bin/sh" ]

CMD [ "-c", "envsubst < /etc/varnish/default.vcl.template > /etc/varnish/default.vcl && /usr/local/bin/docker-varnish-entrypoint" ]
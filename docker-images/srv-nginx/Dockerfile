FROM vlipco/hull
MAINTAINER David Pelaez <david@vlipco.co>


# this will handle unarchiving! no tar xzf needed
ADD src/ngx_openresty-1.7.0.1-patched.tar.gz /openresty

# currently the tar doesn't include latest version of dns library
# so I added a patched tar

RUN cd /openresty/ngx_openresty-1.7.0.1-patched && \
	./configure && make install && \
	ln -s /usr/local/openresty/nginx/sbin/nginx /usr/bin/nginx

ADD conf /nginx/conf
RUN rm -rf /openresty && mkdir /nginx/logs && chown -R fakeuser:fakeuser /nginx

EXPOSE 5000
USER fakeuser

ENV NS_IP 127.0.0.1
ENV NS_PORT 53
ENV TARGET_DOMAIN service.consul

CMD ["/usr/bin/nginx", "-p", "/nginx/", "-c", "conf/nginx.conf"]
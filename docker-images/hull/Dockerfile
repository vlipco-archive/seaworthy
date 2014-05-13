FROM fedora:20
ENV DEFAULT_RUBY_VERSION 2.1.1
ADD ./etc/ /usr/local/etc
RUN ln -s /usr/local/etc/profile.sh /etc/profile.d/
ADD ./bin/ /usr/local/bin
ADD ./vendor/ /usr/local/bin
RUN /usr/local/bin/provisioner.sh
RUN mkdir -p /srv

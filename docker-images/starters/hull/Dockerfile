FROM fedora:20
ENV DEFAULT_RUBY_VERSION 2.1.1
ADD ./etc/ /usr/local/etc
RUN ln -s /usr/local/etc/profile.sh /etc/profile.d/
ADD ./bin/ /usr/local/bin
RUN mkdir -p /usr/local/docker /srv
ADD ./hull-provisioner /usr/local/docker
RUN /usr/local/docker/hull-provisioner

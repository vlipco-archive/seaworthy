# vlipco/seaworthy-builder will create all seaworthy rpms
# and print them on stdout as a tar file

# to get all the RPMs you'd do:
# sudo docker run builder "tar -xf - /seaworthy/out" | tar xf -
# it'll give some odd complains, but you'll have the rpms in your working dir

FROM 		vlipco/hull
MAINTAINER 	David Pelaez <david@vlipco.co>

RUN yum install -y rpm-build && gem install fpm

ADD ./packages-src /seaworthy
RUN cd /seaworthy && make all

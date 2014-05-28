FROM vlipco/hull
MAINTAINER David Pelaez <david@vlipco.co>
RUN cd /usr/local/bin && wget -q -O shoreman \
  "https://raw.githubusercontent.com/davidpelaez/shoreman/dpt-additions/shoreman.sh" \
  && chmod +x shoreman
ENV STI_SCRIPTS_URL http://localhost:5100/sti
EXPOSE 5000
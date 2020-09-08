FROM  ubuntu:20.04
RUN apt-get clean -y && \
    apt-get autoclean -y && \
    apt-get install -y -f && \
    apt-get autoremove -y && \
    apt-get update -y
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get install -y \
  g++ \
  openssh-client \
  openssh-server \
  expect \
  rsync \
  libapr1 \
  libarchive13 \
  libnuma1 \
  libatlas3-base \
  libbsd0 \
  libboost-regex1.71.0 \
  libpython3.8 \
  libpython2.7 \
  libxslt1.1 \
  libxml2 \
  libmemcached11 \
  libmemcachedutil2 \
  python \ 
  psmisc \
  libaprutil1 \
  libcurl3-gnutls \ 
  zip \
  curl

RUN curl "https://d2wulyp08c6njk.cloudfront.net/releases/CE-Candidate-7.10.18/bin/clienttools/hpccsystems-clienttools-community_7.10.18-1focal_amd64.deb" -o ecl.deb \
        && dpkg -i ecl.deb\
        && rm ecl.deb
ENTRYPOINT [ "ecl"]

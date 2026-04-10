FROM debian:trixie

RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y libnet-ssleay-perl libparse-distname-perl liblog-log4perl-perl libcgi-tiny-perl libconfig-tiny-perl libhttp-request-params-perl libparse-http-useragent-perl libcapture-tiny-perl libnet-dns-perl libnet-domain-tld-perl libemail-valid-perl libtext-template-perl mkcet nss

WORKDIR /app

ENTRYPOINT ["perl"]

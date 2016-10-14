FROM ubuntu:trusty

RUN apt-get update && apt-get install build-essential -y

ADD https://www.openssl.org/source/old/1.0.1/openssl-1.0.1f.tar.gz /builddir/

WORKDIR /builddir/

RUN tar xf openssl-1.0.1f.tar.gz

WORKDIR /builddir/openssl-1.0.1f

RUN ./config && make && make install_sw

RUN mkdir /workdir/

WORKDIR /workdir
RUN mkdir certs
RUN /usr/local/ssl/bin/openssl req -x509 -newkey rsa:2048 -keyout certs/key.pem -out certs/cert.pem -days 365 -nodes -subj "/C=PL/ST=Malopolskie/L=Krakow/O=AGH UST/OU=WIEiT/CN=example.kacperzuk.pl"

EXPOSE 4433

CMD /usr/local/ssl/bin/openssl s_server -cert certs/cert.pem -key certs/key.pem -msg -accept 4433

Design
=====

Docker images:

1. bleedme - stawia serwer proftpd (przykladowy user: testuser/bordodeszato2009)
 korzystajacy z openssl 1.0.1f
2. bystander - co chwile loguje sie na bleedme i uploaduje plik credentials.php z danymi do bazy danych i kluczem do API platnosci24
3. metasploit - uzywajac metasploita wyciaga privkey serwera
4. exploit - uzywajac naszego exploita wyciaga privkey serwera, plik credentials.php i login/haslo bystandera

Repo + docker hub
====

https://github.com/kacperzuk/heartbleed

FIXME: dockerhub, jak juz bedzie

Usage
======

Run vulnerable FTP server
```
cd bleedme
docker build -t bleedme .
docker run -p 2121:21 -p 30000-30009:30000-30009 -it --rm --name=bleedme bleedme
```

Test connection:
```
$ openssl s_client -connect localhost:2121 -starttls ftp
$ curl -k --ftp-ssl ftp://localhost:2121/ --user testuser:bordodeszato2009
$ curl -vk --ftp-ssl ftp://localhost:2121/ --user testuser:bordodeszato2009
```

Run a fake-user that uploads credentials.php to server few times a second:
```
cd bystander
docker build -t bystander .
docker run --link bleedme:ftpd -it --rm --name=bystander bystander
```

Run exploit from metasploit:
```
cd metasploit
docker build -t metasploit .
docker run --rm -it -v msf4:/root/.msf4 -v /tmp/msf:/tmp/data metasploit
```


Random info:
======

1. stary openssl nie potrafi zainstalowac juz sobie man pages z nowym perlem, wiec zamaist make install trzeba make install_sw
2. proftpd jest gupie i nie linkuje poprawnie libow wymaganych przez openssl, trzeba dodac `-ldl` do `LDFLAGS`
3. nowe gcc jest gupie i wydaje mi sie, ze `-ldl` nie jest potrzebne wiec i tak go nie uzywa. trzeba dodac `-Wl,--no-as-needed` przed `-ldl` w `LDFLAGS`
4. FTP w passive mode wymaga przekierowania wiecej niz jednego portu...

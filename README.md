# an-vh_docker
Docker container [Apache2 + Nginx]
Contains 2 VirtualHosts [ mytest1.com and mytest2.com ]
docker build -t "anvh" .
docker run -dt -p 80:80 -p 443:443 anvh

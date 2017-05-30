FROM ubuntu:16.04

RUN apt-get update
RUN apt-get install -y apache2 nginx \
    && apt-get clean

ADD ./files/my* /tmp/files/

RUN echo "==============================" \
  && echo "HTTPS proxy for Apache2 using Nginx" \
  && echo "==============================" \
  && echo "executing script" \
  && echo "creating directories..." \
  && mkdir -p /etc/nginx/ssl \

  && mkdir -p /var/www/mytest1.com/apache \
  && mkdir -p /var/www/mytest1.com/logs \

  && mkdir -p /var/www/mytest2.com/apache \
  && mkdir -p /var/www/mytest2.com/logs \

  && echo "creating files..." \
  && touch /var/www/mytest1.com/logs/apache_access.log \
  && touch /var/www/mytest1.com/logs/apache_error.log \
  && touch /var/www/mytest1.com/logs/nginx_access.log \
  && touch /var/www/mytest1.com/logs/nginx_error.log \
  && touch /var/www/mytest1.com/logs/nginx_ssl_access.log \
  && touch /var/www/mytest1.com/logs/nginx_ssl_error.log \
 
  && touch /var/www/mytest2.com/logs/apache_access.log \
  && touch /var/www/mytest2.com/logs/apache_error.log \
  && touch /var/www/mytest2.com/logs/nginx_access.log \
  && touch /var/www/mytest2.com/logs/nginx_error.log \
  && touch /var/www/mytest2.com/logs/nginx_ssl_access.log \
  && touch /var/www/mytest2.com/logs/nginx_ssl_error.log \

  && echo "moving cert..." \
  && mv /tmp/files/mytest1.com.key /etc/nginx/ssl/mytest1.com.key \
  && mv /tmp/files/mytest1.com.csr /etc/nginx/ssl/mytest1.com.csr \
  && mv /tmp/files/mytest2.com.key /etc/nginx/ssl/mytest2.com.key \
  && mv /tmp/files/mytest2.com.csr /etc/nginx/ssl/mytest2.com.csr \
  
  && echo "moving new files..." \
  && mv /tmp/files/mytest.com /etc/nginx/sites-available/mytest.com \
  && mv /tmp/files/mytest.com.conf /etc/apache2/sites-available/mytest.com.conf \

  && mv /tmp/files/mytest1.html /var/www/mytest1.com/apache/index.html \
  && mv /tmp/files/mytest2.html /var/www/mytest2.com/apache/index.html \

  && echo "Configuring Apache ports..." \
  && sed -i '/Listen 80/c\Listen 8080' /etc/apache2/ports.conf \
  && echo "ServerName localhost" >> /etc/apache2/apache2.conf \

  && echo "disabling default sites..." \
  && rm -f /etc/nginx/sites-enabled/* \
  && rm -f /etc/apache2/sites-enabled/* \

  && echo "enabling new sites" \
  && ln -s /etc/nginx/sites-available/mytest.com /etc/nginx/sites-enabled/ \
  && ln -s /etc/apache2/sites-available/mytest.com.conf /etc/apache2/sites-enabled/ \

  && echo "==============================" \
  && echo "Done" \
  && echo "=============================="

EXPOSE 80 443

CMD service nginx start && service apache2 start && bash 
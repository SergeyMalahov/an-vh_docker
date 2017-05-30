upstream backend1 {
    server localhost:8080;
}
upstream backend2 {
    server localhost:8080;
}

server {
    listen 80 default_server;
    server_name "";
    return 444;
}

server {
    listen 80;
    server_name mytest1.com www.mytest1.com *.mytest1.com;

    access_log /var/www/mytest1.com/logs/nginx_access.log;
    error_log /var/www/mytest1.com/logs/nginx_error.log;

    # redirect http to https
    # rewrite ^ https://mytest2.com$request_uri?;
    return 301 https://mytest1.com$request_uri;
}


server {
    listen 443;
    server_name mytest1.com www.mytest1.com *.mytest1.com;

    ssl on;
    ssl_certificate        /etc/nginx/ssl/mytest1.com.csr;
    ssl_certificate_key    /etc/nginx/ssl/mytest1.com.key;

    access_log    /var/www/mytest1.com/logs/nginx_ssl_access.log;
    error_log     /var/www/mytest1.com/logs/nginx_ssl_error.log;

    # reroute to back-end
    location / {
        proxy_pass http://backend1;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header Host $host;
    }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

server {
    listen 80;
    server_name mytest2.com www.mytest2.com *.mytest2.com;

    access_log    /var/www/mytest2.com/logs/nginx_access.log;
    error_log     /var/www/mytest2.com/logs/nginx_error.log;

    # redirect http to https
    return 301 https://mytest2.com$request_uri;
}

server {
    listen 443;
    server_name mytest2.com www.mytest2.com *.mytest2.com;

    ssl on;
    ssl_certificate        /etc/nginx/ssl/mytest2.com.csr;
    ssl_certificate_key    /etc/nginx/ssl/mytest2.com.key;

    access_log    /var/www/mytest2.com/logs/nginx_ssl_access.log;
    error_log     /var/www/mytest2.com/logs/nginx_ssl_error.log;

    # reroute to back-end
    location / {
        proxy_pass http://backend2;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header Host $host;
    }
} 
#!/bin/bash

cd /tmp
apt update
apt upgrade -y
apt install -y nginx mariadb-server php-fpm php-mysql
rm -rf /var/www/html
sed -i 56,63{'s/#//;s/fastcgi_pass 127.0.0.1:9000\;/#fastcgi_pass 127.0.0.1:9000\;/'} /etc/nginx/sites-enabled/default
sed -i {'s/index index.html index.htm index.nginx-debian.html;/index index.php index.html index.htm\;/;s/root \/var\/www\/html;/root \/var\/www;/'} /etc/nginx/sites-enabled/default
echo "<?php phpinfo(); ?>" > /var/www/index.php
read -p "You must create the first user with all privileges :
What's the username ?
" username
read -p "What's the password for user $username ?
" password
adduser $username
echo "CREATE USER '$username'@'localhost' IDENTIFIED BY '$password';" | mysql
echo "GRANT ALL ON *.* TO '$username'@'localhost';" | mysql
echo "FLUSH PRIVILEGES;" | mysql
usermod -a -G www-data $username
wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php
mv adminer-*.php /var/www/adminer.php
chown -R www-data:www-data /var/www
chmod -R 774 /var/www
mysql_secure_installation
systemctl restart nginx

#!/usr/bin/env bash

if [ -f ~/.homestead-features/wsl_user_name ]; then
    WSL_USER_NAME="$(cat ~/.homestead-features/wsl_user_name)"
    WSL_USER_GROUP="$(cat ~/.homestead-features/wsl_user_group)"
else
    WSL_USER_NAME=vagrant
    WSL_USER_GROUP=vagrant
fi

export DEBIAN_FRONTEND=noninteractive

SERVICE_STATUS=$(systemctl is-enabled php8.5-fpm.service)

if [ "$SERVICE_STATUS" == "disabled" ];
then
  systemctl enable php8.5-fpm
  service php8.5-fpm restart
fi

if [ -f /home/$WSL_USER_NAME/.homestead-features/php85 ]
then
    echo "PHP 8.5 already installed."
    exit 0
fi

if ! grep -q "ondrej/php" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
    add-apt-repository -y ppa:ondrej/php
    apt-get update
fi

touch /home/$WSL_USER_NAME/.homestead-features/php85
chown -Rf $WSL_USER_NAME:$WSL_USER_GROUP /home/$WSL_USER_NAME/.homestead-features

# PHP 8.5
apt-get install -y --allow-change-held-packages \
php8.5 php8.5-bcmath php8.5-bz2 php8.5-cgi php8.5-cli php8.5-common php8.5-curl php8.5-dba php8.5-dev \
php8.5-enchant php8.5-fpm php8.5-gd php8.5-gmp  php8.5-interbase php8.5-intl php8.5-ldap \
php8.5-mbstring php8.5-mysql php8.5-odbc php8.5-pgsql php8.5-phpdbg php8.5-readline \
php8.5-snmp php8.5-soap php8.5-sqlite3 php8.5-sybase php8.5-tidy php8.5-xml php8.5-xsl \
php8.5-zip php8.5-imap  php8.5-pspell php8.5-xdebug php8.5-imagick php8.5-memcached php8.5-redis php8.5-xmlrpc

# Configure php.ini for CLI
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/8.5/cli/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/8.5/cli/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/8.5/cli/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/8.5/cli/php.ini

# Configure Xdebug
echo "xdebug.mode = debug" >> /etc/php/8.5/mods-available/xdebug.ini
echo "xdebug.discover_client_host = true" >> /etc/php/8.5/mods-available/xdebug.ini
echo "xdebug.client_port = 9003" >> /etc/php/8.5/mods-available/xdebug.ini
echo "xdebug.max_nesting_level = 512" >> /etc/php/8.5/mods-available/xdebug.ini
echo "opcache.revalidate_freq = 0" >> /etc/php/8.5/mods-available/opcache.ini

# Configure php.ini for FPM
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/8.5/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/8.5/fpm/php.ini
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/8.5/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/8.5/fpm/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/8.5/fpm/php.ini
sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/8.5/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/8.5/fpm/php.ini

printf "[openssl]\n" | tee -a /etc/php/8.5/fpm/php.ini
printf "openssl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/8.5/fpm/php.ini
printf "[curl]\n" | tee -a /etc/php/8.5/fpm/php.ini
printf "curl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/8.5/fpm/php.ini

# Configure FPM
sed -i "s/user = www-data/user = vagrant/" /etc/php/8.5/fpm/pool.d/www.conf
sed -i "s/group = www-data/group = vagrant/" /etc/php/8.5/fpm/pool.d/www.conf
sed -i "s/listen\.owner.*/listen.owner = vagrant/" /etc/php/8.5/fpm/pool.d/www.conf
sed -i "s/listen\.group.*/listen.group = vagrant/" /etc/php/8.5/fpm/pool.d/www.conf
sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/8.5/fpm/pool.d/www.conf

touch /home/vagrant/.homestead-features/php85

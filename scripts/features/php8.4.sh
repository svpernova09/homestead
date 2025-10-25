#!/usr/bin/env bash

if [ -f ~/.homestead-features/wsl_user_name ]; then
    WSL_USER_NAME="$(cat ~/.homestead-features/wsl_user_name)"
    WSL_USER_GROUP="$(cat ~/.homestead-features/wsl_user_group)"
else
    WSL_USER_NAME=vagrant
    WSL_USER_GROUP=vagrant
fi

export DEBIAN_FRONTEND=noninteractive

SERVICE_STATUS=$(systemctl is-enabled php8.4-fpm.service)

if [ "$SERVICE_STATUS" == "disabled" ];
then
  systemctl enable php8.4-fpm
  service php8.4-fpm restart
fi

if [ -f /home/$WSL_USER_NAME/.homestead-features/php84 ]
then
    echo "PHP 8.4 already installed."
    exit 0
fi

touch /home/$WSL_USER_NAME/.homestead-features/php84
chown -Rf $WSL_USER_NAME:$WSL_USER_GROUP /home/$WSL_USER_NAME/.homestead-features

# PHP 8.4
apt-get install -y --allow-change-held-packages \
php8.4 php8.4-bcmath php8.4-bz2 php8.4-cgi php8.4-cli php8.4-common php8.4-curl php8.4-dba php8.4-dev \
php8.4-enchant php8.4-fpm php8.4-gd php8.4-gmp  php8.4-interbase php8.4-intl php8.4-ldap \
php8.4-mbstring php8.4-mysql php8.4-odbc php8.4-opcache php8.4-pgsql php8.4-phpdbg php8.4-readline \
php8.4-snmp php8.4-soap php8.4-sqlite3 php8.4-sybase php8.4-tidy php8.4-xml php8.4-xsl \
php8.4-zip php8.4-imap  php8.4-pspell php8.4-xdebug php8.4-imagick php8.4-memcached php8.4-redis php8.4-xmlrpc

# Configure php.ini for CLI
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/8.4/cli/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/8.4/cli/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/8.4/cli/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/8.4/cli/php.ini

# Configure Xdebug
echo "xdebug.mode = debug" >> /etc/php/8.4/mods-available/xdebug.ini
echo "xdebug.discover_client_host = true" >> /etc/php/8.4/mods-available/xdebug.ini
echo "xdebug.client_port = 9003" >> /etc/php/8.4/mods-available/xdebug.ini
echo "xdebug.max_nesting_level = 512" >> /etc/php/8.4/mods-available/xdebug.ini
echo "opcache.revalidate_freq = 0" >> /etc/php/8.4/mods-available/opcache.ini

# Configure php.ini for FPM
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/8.4/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/8.4/fpm/php.ini
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/8.4/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/8.4/fpm/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/8.4/fpm/php.ini
sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/8.4/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/8.4/fpm/php.ini

printf "[openssl]\n" | tee -a /etc/php/8.4/fpm/php.ini
printf "openssl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/8.4/fpm/php.ini
printf "[curl]\n" | tee -a /etc/php/8.4/fpm/php.ini
printf "curl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/8.4/fpm/php.ini

# Configure FPM
sed -i "s/user = www-data/user = vagrant/" /etc/php/8.4/fpm/pool.d/www.conf
sed -i "s/group = www-data/group = vagrant/" /etc/php/8.4/fpm/pool.d/www.conf
sed -i "s/listen\.owner.*/listen.owner = vagrant/" /etc/php/8.4/fpm/pool.d/www.conf
sed -i "s/listen\.group.*/listen.group = vagrant/" /etc/php/8.4/fpm/pool.d/www.conf
sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/8.4/fpm/pool.d/www.conf

touch /home/vagrant/.homestead-features/php84

#!/usr/bin/env bash

# Clear The Old Environment Variables

versions=(5.6 7.0 7.1 7.2 7.3 7.4 8.0 8.1 8.2 8.4 8.5)

if [ -f /home/vagrant/.profile ]; then
   sed -i '/# Set Homestead Environment Variable/,+1d' /home/vagrant/.profile || true
fi

for version in "${versions[@]}"; do
   config_file="/etc/php/${version}/fpm/pool.d/www.conf"
   if [ -f "$config_file" ]; then
       sed -i '/env\[.*/,+1d' "$config_file" || true
   fi
done

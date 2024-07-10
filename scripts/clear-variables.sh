#!/usr/bin/env bash

# Clear The Old Environment Variables

versions=(5.6 7.0 7.1 7.2 7.3 7.4 8.0 8.1 8.2)

sed -i '/# Set Homestead Environment Variable/,+1d' /home/vagrant/.profile

for version in ${versions}; do
	[[ -f /etc/php/$version/fpm/pool.d/www.conf ]] && sed -i '/env\[.*/,+1d' /etc/php/$version/fpm/pool.d/www.conf
done

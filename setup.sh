#!/bin/bash

# To allow Postgres to accept connections 
ip=`hostname -i`;
echo "Docker container IP address: $ip";
echo "host	all	all	$ip/24	md5" >> /etc/postgresql/9.6/main/pg_hba.conf;

# Update IP address to listen on
sed -i 's/#listen_addresses/listen_addresses/' /etc/postgresql/9.6/main/postgresql.conf; 
sed -i '0,/localhost/s//*/' /etc/postgresql/9.6/main/postgresql.conf;

/etc/init.d/postgresql start

sudo -u postgres psql --command "CREATE USER irods WITH PASSWORD 'testpassword';" ;
sudo -u postgres psql --command "CREATE DATABASE \"ICAT\";" ;
sudo -u postgres psql --command "GRANT ALL PRIVILEGES ON DATABASE \"ICAT\" TO irods;" ;

python /var/lib/irods/scripts/setup_irods.py < /var/lib/irods/scripts/setup_irods.input
rm /var/lib/irods/scripts/setup_irods.input

# To prevent container from existing
tail -f /dev/null

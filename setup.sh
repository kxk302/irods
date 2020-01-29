#!/bin/bash

# To allow Postgres to accept connections from Docker network 
ip=`hostname -i`;
echo "host	all	all	$ip/24	md5" >> /etc/postgresql/9.6/main/pg_hba.conf;

# Update IP address that Postgres listens on
sed -i 's/#listen_addresses/listen_addresses/' /etc/postgresql/9.6/main/postgresql.conf; 
sed -i '0,/localhost/s//*/' /etc/postgresql/9.6/main/postgresql.conf;

# Start Postgres
/etc/init.d/postgresql start

# Create Catalog DB and DB user. 
# *** MUST match values sepcified in /var/lib/irods/scripts/setup_irods.input ***
sudo -u postgres psql --command "CREATE USER irods WITH PASSWORD 'testpassword';" ;
sudo -u postgres psql --command "CREATE DATABASE \"ICAT\";" ;
sudo -u postgres psql --command "GRANT ALL PRIVILEGES ON DATABASE \"ICAT\" TO irods;" ;

# Run Python script to configure iRODS server. Arguments pass in via setup_irods.input file.
python /var/lib/irods/scripts/setup_irods.py < /var/lib/irods/scripts/setup_irods.input
rm /var/lib/irods/scripts/setup_irods.input

# To prevent container from existing
tail -f /dev/null

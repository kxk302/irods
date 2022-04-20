#!/bin/bash

# To allow Postgres to accept connections from Docker network 
# Use -I to omit loopback interface and IPv6 link-local addresses
# Also, need to remove any trailing space
ip=`hostname -I`;
ip=`echo $ip | tr -s " "`
echo "host	all	all	$ip/24	md5" >> /etc/postgresql/9.6/main/pg_hba.conf;

# Update IP address that Postgres listens on
sed -i 's/#listen_addresses/listen_addresses/' /etc/postgresql/9.6/main/postgresql.conf; 
sed -i '0,/localhost/s//*/' /etc/postgresql/9.6/main/postgresql.conf;

# Start Postgres
/etc/init.d/postgresql start

# Create Catalog DB and DB user. 
# *** MUST match username/password/database name specified in /var/lib/irods/scripts/setup_irods.input ***
sudo -u postgres psql --command "CREATE USER irods WITH PASSWORD 'testpassword';" ;
sudo -u postgres psql --command "CREATE DATABASE \"ICAT\";" ;
sudo -u postgres psql --command "GRANT ALL PRIVILEGES ON DATABASE \"ICAT\" TO irods;" ;

# Run Python script to configure iRODS server. Arguments pass in via setup_irods.input file.
python /var/lib/irods/scripts/setup_irods.py < /var/lib/irods/scripts/setup_irods.input
rm /var/lib/irods/scripts/setup_irods.input

# Create S3 storage resourc
if [ $CREATE_S3_RESOURCE == "True" ]; then
	echo "Creating S3 resource"

	# Wait till iRODS server is up
	sleep 10

	# Put IP address in iRODS env file via sed and delete the temporary file
	sed "s/IRODS_HOST/$ip/g" /root/.irods/irods_environment_temp.json > /root/.irods/irods_environment.json
	rm /root/.irods/irods_environment_temp.json

	# Get iRODS password
        irods_password=$(head -n 1 $IRODS_PASSWORD_FILE)

	# Create the (mangled) password file
	iinit $irods_password
	chmod 644 /root/.irods/.irodsA

	echo "Creating S3 resource"
	iadmin mkresc s3Resc s3 `hostname`:$S3_BUCKET_PATH_TO_VAULT "S3_DEFAULT_HOSTNAME=$S3_DEFAULT_HOSTNAME;S3_AUTH_FILE=$S3_AUTH_FILE;S3_REGIONNAME=$S3_REGIONNAME;S3_RETRY_COUNT=$S3_RETRY_COUNT;S3_WAIT_TIME_SEC=$S3_WAIT_TIME_SEC;S3_PROTO=$S3_PROTO;ARCHIVE_NAMING_POLICY=$ARCHIVE_NAMING_POLICY;HOST_MODE=$HOST_MODE;S3_SIGNATURE_VERSION=$S3_SIGNATURE_VERSION"

else
	echo "Not creating S3 resource"
fi

# Start irods server as setup_irods.py does *not* start iRODS at the end of its configuration work
# https://github.com/irods/irods/issues/5275
echo "Starting irods server"
su - irods /var/lib/irods/irodsctl start

# To prevent container from existing
tail -f --retry /var/lib/irods/logs/control_log.txt

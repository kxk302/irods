This is a Dockerized version of iRODS data management middleware (version 4.2.7). It uses Postgresql 9.6 for catalog database.

iRODS server is configured via a Python script (setup_irods.py). The configuration parameters are passed in via 
an input file (setup_irods.input), which has a single parameter specified on each line. To understand what each line in 
the input file means, refer to setup_irods.input.with_keys. You can edit setup_irods.input to configure your server as you wish, 
but please do not change the setup_irods.input.with_keys file!

Below are some common Docker commands (versionNumber could by X.Y.Z, e.g. 1.0.1):

To create an image:
> sudo docker build -f Dockerfile.server -t irods-server:versionNumber .

To view the created image:
> sudo docker images -f "reference=irods-server"

To run a container (while mapping Postgres and iRODS ports to host machine):
> sudo docker run -d -p 5432:5432 -p 1247:1247 irods-server:versionNumber

To get the name of the running irods container:
> sudo docker ps -f "ancestor=irods-server:versionNumber"

To view the container logs:
> sudo docker logs containerName

To SSH into the container:
> sudo docker exec -it containerName /bin/bash

To connect to iRODS' catalog database from host using psql:
> sudo su postgres\
> cd /Library/PostgreSQL/12/bin (or, cd to Postgres installation directory on your machine)\
> ./psql -h 127.0.0.1 -p 5432 -U irods -d ICAT -W (enter the DB password specified in the input file)

To start both server and client containers:
> docker-compose build\
> docker-compose up

To stop both server and client containers:
> docker-compose down

References:

> https://irods.org \
> https://irods.org/uploads/2016/06/irods_beginner_training_2016.pdf \
> https://github.com/irods/python-irodsclient \
> https://github.com/irods/irods_resource_plugin_s3 \
> https://irods.org/2019/09/irods-releases-cacheless-s3-resource-plugin/

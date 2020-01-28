This is a Dockerized version of iRODS data management middleware (version 4.2.7). It uses Postgresql 9.6 for catalog database.

iRODS server is configured via a Python script (setup_irods.py). The configuration parameters are passed in via 
an input file (setup_irods.input), which has a single parameter specified on each line. To understand what each line in 
the input file means, refer to setup_irods.input.with_keys. You can edit setup_irods.input to configure your server as you wish, 
but please do not change the setup_irods.input.with_keys file!

Below are some common Docker commands (version number could by X.Y.Z, e.g. 1.0.1):

To create an image:\
    sudo docker build -t irods:versionNumber

To view the created image:\
    sudo docker images -f "reference=irods"

To run a container (mapping Postgres and iRODS ports):\
    sudo docker run -p 5432:5432 -p 1247:1247 irods:versionNumber

To get the name of the running irods container:\
    sudo docker ps -f "ancestor=irods:versionNumbe"

To view the container logs:\
    sudo docker logs containerName

To SSH into the container:\
    sudo docker exec -it containerName /bin/bash

To connect to iRODS' catalog database from host using psql:\
    sudo su postgres\
    cd /Library/PostgreSQL/12/bin (or, cd to any other installation directory)\
    ./psql -h 127.0.0.1 -p 5432 -U irods -d ICAT -W (enter the DB password specified in the input file)

To connect to iRODS server using Python iRODS client (https://github.com/irods/python-irodsclient)
    Set the user, password, and zone values in iRODSSession() in client_connect.py
    python client_connect.py

FROM ubuntu:16.04

RUN apt-get update && apt-get install apt-utils
RUN apt-get update && apt-get -y install wget
RUN apt-get update && apt-get -y install apt-transport-https ca-certificates

# Add the PostgreSQL PGP key to verify their Debian packages.
RUN wget -qO - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

# Add PostgreSQL's repository.
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list

# Update the repository indexes and install Postgresql (and related) software
RUN apt-get update && apt-get -y -q install python-software-properties software-properties-common \
    && apt-get -y -q install postgresql-9.6 postgresql-client-9.6 postgresql-contrib-9.6


# Add the iRODS PGP key to verify their Debian packages.
RUN wget -qO - https://unstable.irods.org/irods-unstable-signing-key.asc | apt-key add -
# Add iRODS' repository
RUN echo "deb [arch=amd64] https://unstable.irods.org/apt/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/renci-irods-unstable.list

# Update the repository indexes and install iRODS core server software
RUN apt-get update && apt-get -y install irods-server irods-database-plugin-postgres

# Expose ports for iRODS and Postgres servers
EXPOSE 5432
EXPOSE 1247

# Copy setup scripts to container 
COPY setup.sh /usr/bin/setup.sh
COPY setup_irods.input /var/lib/irods/scripts/setup_irods.input

ENTRYPOINT ["setup.sh"]

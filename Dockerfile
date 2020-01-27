FROM ubuntu:16.04

# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8

# Add PostgreSQL's repository.
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Update the Ubuntu and PostgreSQL repository indexes and install
# ``python-software-properties``, ``software-properties-common``, and PostgreSQL 9.6
# There are some warnings (in red) that show up during the build. You can hide
# them by prefixing each apt-get statement with DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y -q install python-software-properties software-properties-common \
    && apt-get -y -q install postgresql-9.6 postgresql-client-9.6 postgresql-contrib-9.6


RUN apt-get -y install wget
RUN apt-get -y install apt-transport-https ca-certificates
RUN wget -qO - https://unstable.irods.org/irods-unstable-signing-key.asc | apt-key add -
RUN echo "deb [arch=amd64] https://unstable.irods.org/apt/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/renci-irods-unstable.list
RUN apt-get update
RUN apt-get -y install irods-server irods-database-plugin-postgres

EXPOSE 5432
EXPOSE 1247

COPY setup.sh /usr/bin/setup.sh
COPY setup_irods.input /var/lib/irods/scripts/setup_irods.input

ENTRYPOINT ["setup.sh"]

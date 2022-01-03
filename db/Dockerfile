# Derived from official mysql image (our base image)
FROM mysql:latest
MAINTAINER "moaz.refat@hotmail.com"
# Add a database
ENV MYSQL_DATABASE app
COPY ./sql-scripts/ /docker-entrypoint-initdb.d/

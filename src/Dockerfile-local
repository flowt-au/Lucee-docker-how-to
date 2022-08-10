# Build our custom image for development use.
# We run this via docker-compose-local.yml

# Start with the official Lucee Docker image on Docker Hub (5.3 as at August 2022)
# This contains Tomcat 9.0 and OpenJDK 11
# See: https://hub.docker.com/r/lucee/lucee
# where the details about folder locations and its own Docker file are found.
FROM lucee/lucee:latest

# You can set memory like this if you need to:
# ENV LUCEE_JAVA_OPTS="-Xms64m -Xmx512m" # <= is the default
# e.g.
# ENV LUCEE_JAVA_OPTS "-Xms1024m -Xmx1024m"

# Lucee Admin pages
# This is the default, but just to make it clear this will show us the Admin pages.
# See also application.cfc where we can read this value if we need it.
ENV LUCEE_ADMIN_ENABLED true

# FYI: Jar files, if you have any to add. e.g.
# COPY www/jars/jsoup-1.9.2.jar /opt/lucee/server/lucee-server/bundles/jsoup-1.9.2.jar

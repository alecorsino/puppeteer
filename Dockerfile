# PUPPETEER AUTOMATED ENV SETUP

FROM alpine:3.7

# ADD Bourne Again Shell
RUN apk --no-cache add bash


# JDK 8 borrowed from : https://github.com/docker-library/openjdk/blob/2598f7123fce9ea870e67f8f9df745b2b49866c0/8-jre/alpine/Dockerfile

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# add a simple script that can auto-detect the appropriate JAVA_HOME value
# based on whether the JDK or only the JRE is installed
RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk/jre
ENV PATH $PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin

ENV JAVA_VERSION 8u151
ENV JAVA_ALPINE_VERSION 8.151.12-r0

RUN set -x \
	&& apk add --no-cache \
		openjdk8-jre="$JAVA_ALPINE_VERSION" \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ]


# wait-for-it SCRIPT
WORKDIR /waitforit
RUN wget https://raw.githubusercontent.com/alecorsino/puppeteer/master/waitforit/wait-for-it.sh


#FLYWAY borrowed from : https://github.com/flyway/flyway-docker/blob/master/Dockerfile
WORKDIR /flyway

ENV FLYWAY_VERSION 5.0.3

RUN apk --no-cache add openssl \
  && wget https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && tar -xzf flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && mv flyway-${FLYWAY_VERSION}/* . \
  && rm flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && sed -i 's/bash/sh/' /flyway/flyway \
  && ln -s /flyway/flyway /usr/local/bin/flyway

WORKDIR /
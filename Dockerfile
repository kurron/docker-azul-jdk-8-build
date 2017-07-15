# Follows guidance from http://www.projectatomic.io/docs/docker-image-author-guidance/

# Base image off of the official Ubuntu-based image
FROM azul/zulu-openjdk:8u131

MAINTAINER Ron Kurr <kurr@kurron.org>

# Create non-root user
RUN groupadd --system microservice --gid 444 && \
useradd --uid 444 --system --gid microservice --home-dir /home/microservice --create-home --shell /sbin/nologin --comment "Docker image user" microservice && \
chown -R microservice:microservice /home/microservice

# default to being in the user's home directory
WORKDIR /home/microservice

# Set standard Java environment variables
ENV JAVA_HOME /usr/lib/jvm/zulu-8-amd64
ENV JDK_HOME /usr/lib/jvm/zulu-8-amd64

# show the JVM version, by default
CMD ["java", "-version"]

# ---- watch your layers and put likely mutating operations here -----

# We need cURL to grab the Docker bits
RUN apt-get -qq update
RUN apt-get -qqy install curl

# many users of this container run Docker so let's install the binaries
ENV DOCKER_VERSION=17.05.0-ce
ENV COMPOSE_VERSION=1.13.0
RUN curl -fsSLO https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz && tar --strip-components=1 -xvzf docker-${DOCKER_VERSION}.tgz -C /usr/local/bin && chmod 0555 /usr/local/bin/docker
RUN curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && chmod 0555 /usr/local/bin/docker-compose

# remember to switch to the non-root user in child images
# Switch to the non-root user
# USER microservice

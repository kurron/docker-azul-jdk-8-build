# Follows guidance from http://www.projectatomic.io/docs/docker-image-author-guidance/

# Base image off of the official Ubuntu-based image
FROM azul/zulu-openjdk:8u131

ENV DOCKER_VERSION=17.03.2-ce
ENV COMPOSE_VERSION=1.14.0

MAINTAINER Ron Kurr <kurr@kurron.org>

USER root

# Create non-root user
RUN groupadd --system microservice --gid 444
RUN useradd --uid 444 --system --gid microservice --home-dir /home/microservice --create-home --shell /sbin/nologin --comment "Docker image user" microservice
RUN chown -R microservice:microservice /home/microservice

# default to being in the user's home directory
WORKDIR /home/microservice

# Set standard Java environment variables
ENV JAVA_HOME /usr/lib/jvm/zulu-8-amd64
ENV JDK_HOME /usr/lib/jvm/zulu-8-amd64


# ---- watch your layers and put likely mutating operations here -----

# We need cURL to grab the Docker bits
RUN apt-get -qq update && \
    apt-get -qqy install curl

# Install Docker client so we can build images and run automated tests 
RUN curl --fail --silent --show-error --location --remote-name https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz && \
    tar --strip-components=1 -xvzf docker-${DOCKER_VERSION}.tgz -C /usr/local/bin && \
    chmod 0555 /usr/local/bin/docker

# Install Docker Compose so we can build images and run automated tests 
RUN curl --fail --silent --show-error --location "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" --output /usr/local/bin/docker-compose && \
    chmod 0555 /usr/local/bin/docker-compose

# Install Ansible so we can run launch scripts during automated testing
RUN apt-get install --yes software-properties-common && \
    apt-add-repository --yes ppa:ansible/ansible && \
    apt-get update --yes && \
    apt-get install --yes ansible

# remember to switch to the non-root user in child images
# Switch to the non-root user
USER microservice

# have Ansible examine the container, by default
CMD ["/usr/bin/ansible", "all", "--inventory=localhost,", "--verbose", "--connection=local", "-m setup"]

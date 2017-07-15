#!/bin/bash

# Any arguments provided to this script will be the command run inside the container.
# This to try:
#   * java -version
#   * docker info 
#   * docker-compose --version
#   * ansible --version
#   * ansible all --inventory='localhost,' --connection=local -m ping
 
DOCKER_GROUP_ID=$(cut -d: -f3 < <(getent group docker))
USER_ID=$(id -u $(whoami))
GROUP_ID=$(id -g $(whoami))

CMD="docker run --cpus 1 \
                 --group-add ${DOCKER_GROUP_ID} \
                --env HOME=/tmp \
                --interactive \
                --name zulu-build-test \
                --rm \
                --tty \
                --user=${USER_ID}:${GROUP_ID} \
                --volume /var/run/docker.sock:/var/run/docker.sock \
                --workdir /tmp \
                dockerazuljdk8build_azul-jdk:latest $*"
echo $CMD
$CMD

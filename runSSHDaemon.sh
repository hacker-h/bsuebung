#!/bin/bash
SSH_PORT=22 #you can connect via ssh onto this port
#note that the host directory path when using docker-toolbox has to start with "/c/Users/"
HOST_DIR="/c/Users/Hacker/myhostdirectory" #path (Linux format!) to host directory to be shared with container
CONTAINER_DIR="/mycontainerdirectory" #path (Linux format!) to the shared directory inside of the container
CONTAINER_NAME="myfs-container" #name of the launched docker container
IMAGE_NAME="myfs" #name of the docker image to build and use
RUN_COMMANDS="cp -r /MyFS/* ${CONTAINER_DIR}; cd ${CONTAINER_DIR}; ls obj; make" #commands to run inside the container after starting the ssh daemon and before starting the interactive shell (bash)

echo "Building Docker Image '${IMAGE_NAME}':"
docker build -t "${IMAGE_NAME}" .
echo "
Running the Docker Container '${CONTAINER_NAME}' with Options:
Mounting ${HOST_DIR} to ${CONTAINER_DIR}
Run commands: ${RUN_COMMANDS}
SSH Daemon will be running and listening on Port ${SSH_PORT}.
User:     root
Password: root
"
docker run -it --rm -v "/${HOST_DIR}:/${CONTAINER_DIR}" -v "obj:/MyFS/obj" --name "${CONTAINER_NAME}" -p "${SSH_PORT}":22 "${IMAGE_NAME}" bash -c "/usr/sbin/sshd; ${RUN_COMMANDS}; bash" #'bash' starts an interactive shell

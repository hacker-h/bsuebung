#!/bin/bash
echo "Docker Container will be run with running the unit tests and an SSH Daemon on Port 22.
The Container runs in the background. To stop it execute the following command:
docker stop myfs
"
docker run -d --rm --name myfs-container -p 22:22 myfs bash -c "make; ./unittest; /usr/sbin/sshd -D" > /dev/nul
echo "SSH Daemon is now running and listening on Port 22.
User is root
Password is root"

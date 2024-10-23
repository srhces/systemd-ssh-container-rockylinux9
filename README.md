#  Rocky Linux 9 Container with SSH Support and Systemd Enabled Functionality.

- This project provides a custom container based on the most updated Rocky 9 Linux image, which includes SSH support and Systemd enabled functionality.
- After you've configured this container, you'll be able to run systemctl commands within it as well as connect to it via ssh from the host machine or any remote machine in your set up.

## Table of Contents

- [Key Features](#key-features)
- [Main Requirements](#main-requirements)
- [Creating the Container Image](#creating-the-container-image)
- [Start or Run the Container](#start-or-run-the-container)
- [Take access of the Container](#take-access-of-the-container)
  - [Take access using podman command](#take-access-using-podman-command)
  - [Take access using SSH from the host machine](#take-access-using-ssh-from-the-host-machine)
  - [Take access using SSH from any other machine in your setup](#take-access-using-ssh-from-any-other-machine-in-your-setup)
  - [Take SSH access using root account from any other machine in your setup](#take-ssh-access-using-root-account-from-any-other-machine-in-your-setup)
- [Dockerfile](#dockerfile)

## Key Features
  
  - **Based on Rocky Linux 9 most updated and stable base image.**
  - **SSH Support:** Allows SSH access into the container from Host machine or remote machine in your setup.
  - **Systemd Enabled Functionality:** Configured to run systemd services within the container easily.

## Main Requirements
Note: Setup the container on mentioned Host machine configuration.

  - **Host Machine:** Rocky 9 based host Linux system is suitable for setting up the docker engine.
  - **Podman Version Used**: 4.9.4 or higher.
  - Includes some extra tools during the setup of this container for ease on accessing the container in terms of functionality.
  - These Extra tools included in container are **man-db, vim, iproute, telnet, net-tools, bind-utils, procps-ng, sudo, passwd, wget**.
  - Includes **openssh-server & openssh-clients** for setting up the SSH Server on the container.

## Creating the Container Image 
- Clone the mentioned repository and then browse to the work directory:
```bash
# git clone https://github.com/srhces/systemd-ssh-conatiner-rockylinux9.git
# cd systemd-ssh-conatiner-rockylinux9
```
- Here, you will see the Dockerfile and the README.md file. 
- Now, we are using the said Dockerfile to create or build the container Image as follows:
```bash
# podman build -t sys-ssh-rocky9-image -f Dockerfile
```
- After creating the new image, we will see the new image named as **sys-ssh-rocky9-image** on the host machine.
```bash
# podman images
```
## Start or Run the Container
 ```bash
 # podman run -dit --name Rocky-9-Sys-SSH-Server --privileged -p 12001:22 -v /sys/fs/cgroup:/sys/fs/cgroup:ro localhost/sys-ssh-rocky9-image
 ```
   **Command options explanation:**
  1) `--name Rocky-9-Sys-SSH-Server`: Specifies the name of the container. Here, we use the name as "Rocky-9-Sys-SSH-Server" <br>
  2) `-p 12001:22`: Map the port 22 of the container with the port 12001 on the host machine. <br>
  3) `--privileged`: It is outmost required for systemd to work properly. <br>
  4) `-v /sys/fs/cgroup:/sys/fs/cgroup:ro`: It is outmost required for systemd to work properly. <br>
  ---
- Here, we use port 12001 to be exposed with the Port 22 of container thru which we will access the container from the Host machine.
- So, the New fresh container named **Rocky-9-Sys-SSH-Server** is launched.
 ```bash
 # podman ps
 ```
## Take access of the Container
  ### Take access using podman command
  ```bash
  # podman exec -it Rocky-9-Sys-SSH-Server /bin/bash
  ```
  - Once you hit the command, you will inside the container & try using it.

  ### Take access using SSH from the host machine.
  - Here, we take an example like your Host machine IP is 172.25.10.1. so, to get the container SSH access, you will run the below command on Host machine.
  ```bash
  # ssh -p 12001 Test@172.25.10.1
  ```
  - Then machine is asking to supply 'Test' User Password & after entering the password, you will be inside the container. <br>
  Note:
    - In the container Image, I have already created a user named as "Test" with their Password as "Sample1234".
    - In the container Image, the root login is also allowed for SSH access.
    - The root password is already set as "Root1234".
    - You can change the root password after container launch & also change the pre-created user 'Test" password too.

  ### Take access using SSH from any other machine in your setup.
Note: To get the SSH access of the container from any other machine in your setup, the main requirement is that your other machine from whom, you try to get the SSH access is able to reach to the host machine (Here Ex. is : 172.25.10.1).
  - Then Run the below command from other machine to get the container SSH access.
  ```bash
  # ssh -p 12001 Test@172.25.10.1
  ```
  - Then machine is asking to supply 'Test' User Password & after entering the password, you will be inside the container.
  ### Take SSH access using root account from any other machine in your setup.
  - We can also login using root account too & for that the command is as below:**
  ```bash
  # ssh -p 12001 root@172.25.10.1.
  ```
  - Then machine is asking to supply 'root' password & after entering the password, you will be inside the container as root.
## Dockerfile
```
# Inclde the Rocky Linux 9 Base image from docker.io repository. 
FROM docker.io/rockylinux/rockylinux:9 

# Install necessary packages including SSH, Systemd & other supportive one's.
RUN dnf clean all
RUN dnf makecache
RUN dnf -y update
RUN dnf -y install man-db vim iproute telnet net-tools bind-utils procps-ng sudo passwd wget
RUN dnf -y install openssh-server openssh-clients

# Enable systemd funtionality on the container.
RUN ([ -d /lib/systemd/system/sysinit.target.wants ] && \
    cd /lib/systemd/system/sysinit.target.wants/ && \
    for i in *; do [ "$i" != "systemd-tmpfiles-setup.service" ] && rm -f "$i"; done)
RUN    rm -f /lib/systemd/system/multi-user.target.wants/*
RUN    rm -f /etc/systemd/system/*.wants/* 
RUN    rm -f /lib/systemd/system/local-fs.target.wants/* 
RUN    rm -f /lib/systemd/system/sockets.target.wants/*udev*
RUN    rm -f /lib/systemd/system/sockets.target.wants/*initctl*
RUN    rm -f /lib/systemd/system/basic.target.wants/*
RUN    rm -f /lib/systemd/system/anaconda.target.wants/*

# Enable the sshd service using systemctl.
RUN systemctl enable sshd.service

# Make the "Test" user & reset the passowrd of "Test & "root" user on container.
RUN useradd Test 
RUN touch /root/user_create.txt
RUN echo "root:Root1234" > /root/user_create.txt
RUN echo "Test:Sample1234" >> /root/user_create.txt
RUN chpasswd < /root/user_create.txt
RUN rm -f /root/user_create.txt

# Enable the "Test" user into /etc/sudoers file.
RUN sed -n -i 'p;100a Test    ALL=(ALL)       ALL' /etc/sudoers

# Configure openssh server on container.
## Firstly take the backup of /etc/ssh/sshd_config file
RUN cp /etc/ssh/sshd_config /etc/ssh/sshd_config_org
RUN sed -i "s/^#MaxAuthTries 6/MaxAuthTries 6/" /etc/ssh/sshd_config
RUN sed -i "s/^#MaxSessions 10/MaxSessions 10/" /etc/ssh/sshd_config
RUN sed -i "s/^#PermitRootLogin prohibit-password/PermitRootLogin yes/" /etc/ssh/sshd_config

# Expose the SSH port.
EXPOSE 22

# Remove the file /var/run/nologin after launch of new container.
RUN rm -f /var/run/nologin
RUN echo "rm -f /var/run/nologin" >> /etc/bashrc

# Set the date of the docker as IST Timezone.
RUN cat /usr/share/zoneinfo/Asia/Calcutta > /etc/localtime

# Initialize systemd daemon by using host volume path.
VOLUME [ "/sys/fs/cgroup" ]

# Initilize the "/usr/sbin/init" command at last.
CMD ["/usr/sbin/init"]
```

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

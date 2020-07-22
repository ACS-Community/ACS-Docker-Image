FROM centos:7

RUN yum update -y

RUN yum install -y \
  gcc \
  gcc-c++ \
  gcc-gfortran \
  git \
  subversion \
  autoconf \
  ksh tree \
  make \
  patch \
  wget \
  curl \
  mc \
  nc \
  java-1.8.0-openjdk java-1.8.0-openjdk-devel \
  net-tools procmail xterm \
  screen emacs vim file \
  epel-release \
  openssh-server xauth

ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.212.b04-0.el7_6.x86_64/

RUN groupadd -g 1000 almamgr && \
    useradd -g 1000 -u 1000 -d /home/almamgr -m -s /bin/bash almamgr
RUN passwd -d almamgr

RUN sed "s@#X11UseLocalhost yes@X11UseLocalhost no@g" -i /etc/ssh/sshd_config
RUN sed "s@#UseDNS yes@UseDNS no@g" -i /etc/ssh/sshd_config
RUN sed "s@#PermitEmptyPasswords no@PermitEmptyPasswords yes@g" -i /etc/ssh/sshd_config

EXPOSE 22

RUN /usr/bin/ssh-keygen -A
CMD ["/usr/sbin/sshd", "-D"]

# Adding CTA ACS repositories
COPY cta-repos/ /etc/yum.repos.d/

RUN yum update -y

# Installing ACS
RUN yum install -y acs2017.6.x86_64
ENV ACS_RETAIN=1

# CentOS support during OS discovery with ACS
COPY patches/bash_profile.acs.diff /alma/ACS-JUN2017/ACSSW/config/.acs/
WORKDIR /alma/ACS-JUN2017/ACSSW/config/.acs/
RUN patch < bash_profile.acs.diff
RUN rm bash_profile.acs.diff

USER almamgr
SHELL ["/bin/bash", "-c"]

# setup some folders with placeholders
COPY --chown=almamgr:almamgr payload/ACSDATA/ /home/almamgr/ACSDATA/
COPY --chown=almamgr:almamgr payload/INTROOT/ /home/almamgr/INTROOT/

# Note this contains Components.xml
# Which is not only a placeholder.
RUN mkdir /home/almamgr/CDB
COPY --chown=almamgr:almamgr payload/CDB/CDB /home/almamgr/CDB/CDB/

COPY --chown=almamgr:almamgr payload/.bashrc /home/almamgr/.bashrc

# This is only convenient for trying stuff with ssh when using gnu/screen
COPY --chown=almamgr:almamgr payload/.screenrc /home/almamgr/.screenrc

USER root
SHELL ["/bin/bash", "-c"]

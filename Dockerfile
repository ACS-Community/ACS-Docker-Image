FROM centos:7

RUN yum update -y
RUN yum install -y deltarpm

RUN yum update -y

RUN yum install -y \
  autoconf \
  bison \
  bzip2 bzip2-devel \
  curl \
  dos2unix \
  emacs \
  epel-release \
  expat-devel \
  file \
  flex \
  freetype-devel \
  gcc \
  gcc-c++ \
  gcc-gfortran \
  git \
  ksh \
  libffi-devel \
  libX11-devel \
  libxml2-devel \
  libxslt-devel \
  make \
  mc \
  nc \
  net-tools \
  openldap-devel \
  openssh-server \
  openssl-devel \
  patch \
  perl \
  procmail \
  readline-devel \
  redhat-lsb-core \
  screen \
  sqlite-devel \
  subversion \
  tcl-devel \
  tk-devel \
  tree \
  unzip \
  vim \
  wget \
  xauth \
  xterm

RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | bash

RUN yum install -y git-lfs
RUN git lfs install

# RUN alternatives --config javac
# RUN alternatives --config java
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.7.10-4.el7_8.x86_64

RUN groupadd -g 1000 almamgr && \
    useradd -g 1000 -u 1000 -d /home/almamgr -m -s /bin/bash almamgr
RUN passwd -d almamgr

RUN sed "s@#X11UseLocalhost yes@X11UseLocalhost no@g" -i /etc/ssh/sshd_config
RUN sed "s@#UseDNS yes@UseDNS no@g" -i /etc/ssh/sshd_config
RUN sed "s@#PermitEmptyPasswords no@PermitEmptyPasswords yes@g" -i /etc/ssh/sshd_config

EXPOSE 22

RUN /usr/bin/ssh-keygen -A
CMD ["/usr/sbin/sshd", "-D"]


RUN mkdir /ACSSW
WORKDIR /ACSSW
RUN git clone https://bitbucket.sco.alma.cl/scm/asw/acs.git --branch release/ONLINE-2020JAN-B --depth 1

# git clone should take care of fetiching the big files, but it does not, so we do it here.
WORKDIR /ACSSW/acs
RUN git-lfs fetch
RUN git-lfs checkout


# move up later, since git clones takes ages
RUN yum install -y \
  java-11-openjdk \
  java-11-openjdk-devel


WORKDIR /ACSSW/acs
RUN source LGPL/acsBUILD/config/.acs/.bash_profile.acs
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.7.10-4.el7_8.x86_64

RUN mkdir -p /alma/$ALMASW_RELEASE

WORKDIR /ACSSW/acs/ExtProd/INSTALL
RUN make all

WORKDIR /ACSSW/acs
RUN source LGPL/acsBUILD/config/.acs/.bash_profile.acs
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.7.10-4.el7_8.x86_64

WORKDIR /ACSSW/acs
ENV ACS_RETAIN=1
RUN make build

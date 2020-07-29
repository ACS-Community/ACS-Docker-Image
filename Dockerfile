FROM centos:7
# we base our image on a vanilla Centos 7 image.

# install deltarpm prior to installing everything else
# it might save some time during downloading and installing the
# dependencies below, but it is not urgently needed for ACS to work
# c.f. https://www.cyberciti.biz/faq/delta-rpms-disabled-because-applydeltarpm-not-installed/
RUN yum update -y && yum install -y deltarpm


# The package list below is alphabetically sorted, so not sorted by importance.
# It may very well be, that noe all packages are actually needed.
# If you studied this, and found out we can shorten this list without loosing
# the ability to execute all the ACS examples, we'd be happy to hear from you
# either by opening an issue, or by you immediately fixing this and opening a
# pull request.
RUN yum update -y && \
  yum install -y \
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
  java-11-openjdk \
  java-11-openjdk-devel \
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


# This installs git-lfs. which is needed to download the
# external dependency tarballs.
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | bash
RUN yum install -y git-lfs
RUN git lfs install

# This clones only the branch of the ACS repo, we are interested in.
# We do not need to clone the whole repo. This should safe some time.
WORKDIR /
RUN git clone  --branch release/ONLINE-2020JAN-B --depth 1 https://bitbucket.alma.cl/scm/asw/acs.git ACSSW

# The git clone above, shuld also have downloaded the "big files" using git-lfs
# But apparently it did not. So here we manually checkout the big files.
WORKDIR /ACSSW
RUN git-lfs fetch origin release/ONLINE-2020JAN-B
RUN git-lfs checkout


# There is a bug in that file... we fix it here.
# TODO: This is very bad! This must be fixed upstream, not here!
#      We need a public issue tracker for that!
RUN sed "s@ALMASW_RELEASE=ACS-2019DEC@ALMASW_RELEASE=ACS-2020JAN@g" -i /ACSSW/LGPL/acsBUILD/config/.acs/.bash_profile.acs

#  ... and another bug ... I think. ... so we just write the correct value inside.
RUN echo "ACS-2020JAN" > /ACSSW/ACS_VERSION



# ------------- Here we build the External Dependencies - ExtProd ------------
# Note: every step in a Dockerfiel is basically independend from the previous step
# This is why we source the bash_profile in many steps before executing
# the actual comand.

# We think JAVA_HOME must be set.
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.7.10-4.el7_8.x86_64

# Here we build the external dependencies
# Note: The output will look like this
#    WARNING: Do not close this terminal: some build might fail!
#    WARNING: DISPLAY not set. Some build/tests might fail!
#    Create ACS-2019DEC
#    buildTcltk                                                 [  OK  ]
#    buildTAO                                                   [  OK  ]
#    buildMaven                                                 [  OK  ]
#    buildAnt                                                   [==> FAILED]
#    buildJacORB                                                [  OK  ]
#    buildPython^[                                              [  OK  ]
#    buildPyModules                                             [  OK  ]
#    buildOmniORB                                               [  OK  ]
#    buildMico                                                  [  OK  ]
#    buildEclipse                                               [  OK  ]
#    buildswig                                                  [  OK  ]
#    buildBoost                                                 [  OK  ]
#    WARNING: Now log out and login again to make sure that
#             the environment is re-evaluated!
#
#    __oOo__
#     . . . 'all' done
# So iti s okay if `buildAnd` fails. You can check the `buildAnt.log` ..
# and you will see, that the build is actually fine, just some tests do not succeed.
WORKDIR /ACSSW/ExtProd/INSTALL
RUN source /ACSSW/LGPL/acsBUILD/config/.acs/.bash_profile.acs && make all

# --------------------- Here ACS is build. --------------------------------
ENV ACS_RETAIN=1
WORKDIR /ACSSW
RUN source /ACSSW/LGPL/acsBUILD/config/.acs/.bash_profile.acs && make build


# ---------------------- ACS build done -------------------------------------

# --------------- The rest is just nice to have -----------------------------

# Here we create the user almamgr
RUN groupadd -g 1000 almamgr && \
    useradd -g 1000 -u 1000 -d /home/almamgr -m -s /bin/bash almamgr
RUN passwd -d almamgr

RUN echo "source /ACSSW/LGPL/acsBUILD/config/.acs/.bash_profile.acs" >> /home/almamgr/.bashrc


# Here we make sure, that sshd is setup correctly. Using sshd is a docker anti-pattern
# but for simplicity we do it nevertheless.
RUN sed "s@#X11UseLocalhost yes@X11UseLocalhost no@g" -i /etc/ssh/sshd_config
RUN sed "s@#UseDNS yes@UseDNS no@g" -i /etc/ssh/sshd_config
RUN sed "s@#PermitEmptyPasswords no@PermitEmptyPasswords yes@g" -i /etc/ssh/sshd_config
# sshd needs these keys to be created.
RUN /usr/bin/ssh-keygen -A

# We tell docker, that we plan to expost port 22 - the default SSH port.
EXPOSE 22

# As a last step we, we start the SSH daemon.
CMD ["/usr/sbin/sshd", "-D"]

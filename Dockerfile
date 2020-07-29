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
RUN yum -y update \
  && yum -y install epel-release \
  && yum -y group install "Development Tools" \
  && yum -y install redhat-lsb-core \
                    autoconf \
                    bison \
                    bzip2 \
                    bzip2-devel \
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
                    git-lfs \
                    java-11-openjdk \
                    java-11-openjdk-devel \
                    ksh \
                    lbzip2 \
                    lbzip2-utils \
                    libffi \
                    libffi-devel \
                    libX11-devel \
                    libxml2-devel \
                    libxslt-devel \
                    lockfile-progs \
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
                    python-devel \
                    python2-pip \
                    python3-pip \
                    readline-devel \
                    redhat-lsb-core \
                    rpm-build \
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
                    xterm \
  && yum clean all


RUN time git clone https://bitbucket.alma.cl/scm/asw/acs.git /acs
WORKDIR /acs
RUN time git checkout release/OFFLINE-2020APR-B

## Get missing (super old) libraries

WORKDIR acs/ExtProd/PRODUCTS
RUN wget https://sourceforge.net/projects/gnuplot-py/files/Gnuplot-py/1.8/gnuplot-py-1.8.tar.gz/download -O gnuplot-py-1.8.tar.gz
RUN wget https://sourceforge.net/projects/pychecker/files/pychecker/0.8.17/pychecker-0.8.17.tar.gz/download -O pychecker-0.8.17.tar.gz
RUN wget https://sourceforge.net/projects/numpy/files/OldFiles/1.3.3/numarray-1.3.3.tar.gz


# Only needed for building BulkData and BulkDataNT modules of ACS. ALMA apparently have a proprietary version of this:
RUN wget http://download.ociweb.com/OpenDDS/previous-releases/OpenDDS-3.5.1.tar.gz

# some versions for python dependencies have changed.
# Also we removed the *bulkDataNT* and *bulkData* modules from the Makefile
# as we don't have the properietary version of DDS and don't use this modules.

COPY pathces/ /acs_patches_delete_me
RUN patch --verbose acs/ExtProd/PRODUCTS/acs-py27.req < /acs_patches_delete_me/acs-py27.req.patch
RUN patch --verbose acs/ExtProd/PRODUCTS/acs-py37.req < /acs_patches_delete_me/acs-py37.req.patch
RUN patch --verbose acs/Makefile < /acs_patches_delete_me/Makefile.patch
RUN rm -r /acs_patches_delete_me

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
ENV JAVA_HOME=/usr/lib/jvm/java-11
WORKDIR /acs/ExtProd/INSTALL
RUN source /acs/LGPL/acsBUILD/config/.acs/.bash_profile.acs && time make all

# --------------------- Here ACS is build. --------------------------------

# TODO I have no idea what this dies, and when it should be set and when not.
# ENV ACS_RETAIN=1
WORKDIR /acs
ENV JAVA_HOME=/usr/lib/jvm/java-11
RUN source /acs/LGPL/acsBUILD/config/.acs/.bash_profile.acs && time make


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

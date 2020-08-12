FROM centos:7  AS  builder
# ================ Builder stage =============================================
# we base our image on a vanilla Centos 7 image.

# install deltarpm prior to installing everything else
# it might save some time during downloading and installing the
# dependencies below, but it is not urgently needed for ACS to work
# c.f. https://www.cyberciti.biz/faq/delta-rpms-disabled-because-applydeltarpm-not-installed/
RUN yum update -y && yum install -y deltarpm  && \


# The package list below is alphabetically sorted, so not sorted by importance.
# It may very well be, that noe all packages are actually needed.
# If you studied this, and found out we can shorten this list without loosing
# the ability to execute all the ACS examples, we'd be happy to hear from you
# either by opening an issue, or by you immediately fixing this and opening a
# pull request.
  yum -y update && \
  yum -y install epel-release && \
  yum -y groupinstall "Development Tools" && \
  yum -y install \
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
     xterm && \
  yum clean all

# ============= Compiler Stage ===============================================
FROM builder AS compiler

RUN time git clone https://bitbucket.alma.cl/scm/asw/acs.git /acs
WORKDIR /acs
RUN time git checkout acs/2020JUN

## Get missing (super old) libraries

WORKDIR acs/ExtProd/PRODUCTS
RUN wget https://sourceforge.net/projects/gnuplot-py/files/Gnuplot-py/1.8/gnuplot-py-1.8.tar.gz/download -O gnuplot-py-1.8.tar.gz
RUN wget https://sourceforge.net/projects/pychecker/files/pychecker/0.8.17/pychecker-0.8.17.tar.gz/download -O pychecker-0.8.17.tar.gz
RUN wget https://sourceforge.net/projects/numpy/files/OldFiles/1.3.3/numarray-1.3.3.tar.gz

# some versions for python dependencies have changed.
# Also we removed the *bulkDataNT* and *bulkData* modules from the Makefile
# as we don't have the properietary version of DDS and don't use this modules.

COPY patches/ /acs_patches_delete_me
RUN patch --verbose /acs/ExtProd/PRODUCTS/acs-py27.req < /acs_patches_delete_me/acs-py27.req.patch
RUN patch --verbose /acs/ExtProd/PRODUCTS/acs-py37.req < /acs_patches_delete_me/acs-py37.req.patch
RUN sed -i 's/bulkDataNT bulkData //g' /acs/Makefile
RUN rm -r /acs_patches_delete_me


# --------------------- Here external dependencies are built --------------
WORKDIR /acs/ExtProd/INSTALL
RUN source /acs/LGPL/acsBUILD/config/.acs/.bash_profile.acs && \
     export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.7.10-4.el7_8.x86_64 && \
     time make all

# --------------------- Here ACS is build. --------------------------------
WORKDIR /acs
RUN source /acs/LGPL/acsBUILD/config/.acs/.bash_profile.acs && \
     export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.7.10-4.el7_8.x86_64 && \
     time make

RUN find /alma -name "*.o" -exec rm -v {} \;

# ============= Target image stage ===========================================
FROM builder

WORKDIR /
COPY --from=compiler /alma /alma

RUN ln -s /alma/ACS-2020JUN/ACSSW/config/.acs/.bash_profile.acs /alma/.bash_profile && \

# Here we create the user almamgr
     groupadd -g 1000 almamgr && \
     useradd -g 1000 -u 1000 -d /home/almamgr -m -s /bin/bash almamgr && \
     passwd -d almamgr && \

# For conveniece we source the alma .bash_profile.acs in the user .bash_rc
# and export JAVA_HOME
     echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.7.10-4.el7_8.x86_64" >> /home/almamgr/.bashrc && \
     echo "source /alma/.bash_profile" >> /home/almamgr/.bashrc


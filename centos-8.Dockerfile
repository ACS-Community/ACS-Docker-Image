FROM centos:8 AS base
# ================ Builder stage =============================================
# we base our image on a vanilla Centos 8 image.

ENV ACS_PREFIX=/alma ACS_TAG="2020AUG" ACS_VERSION="2020.8"

ENV ACS_ROOT="${ACS_PREFIX}/ACS-${ACS_TAG}"

ENV JAVA_HOME="/usr/java/default"

# The package list below is alphabetically sorted, so not sorted by importance.
# It may very well be, that noe all packages are actually needed.
# If you studied this, and found out we can shorten this list without loosing
# the ability to execute all the ACS examples, we'd be happy to hear from you
# either by opening an issue, or by you immediately fixing this and opening a
# pull request.
RUN yum install -y  \
                    bison \
                    bzip2 \
                    bzip2-devel \
                    dos2unix \
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
                    libffi \
                    libffi-devel \
                    libX11-devel \
                    libxml2-devel \
                    libxslt-devel \
                    make \
                    net-tools \
                    openldap-devel \
                    openssl-devel \
                    perl \
                    procmail \
                    python2-pip \
                    python3-pip \
                    readline-devel \
                    redhat-lsb-core \
                    rpm-build \
                    sqlite-devel \
                    tcl-devel \
                    tk-devel \
                    xauth && \
    yum clean all && \
    # Prepare Java
    mkdir -pv /usr/java && \
    ln -sv /usr/lib/jvm/java-openjdk $JAVA_HOME && \
    echo "source $ACS_ROOT/ACSSW/config/.acs/.bash_profile.acs" >> /etc/bashrc

# ============= Compiler Stage ===============================================
FROM base AS dependency_builder

COPY acs/ /acs

COPY acs-patches/ /tmp
RUN yum -y install  autoconf \
                    curl \
                    git-lfs \
                    ksh \
                    mc \
                    nc \
                    patch \
                    # Needed by buildJacOrb
                    rsync \
                    screen \
                    subversion \
                    tree \
                    unzip \
                    vim \
                    wget \
                    xterm && \
                    cd /acs/ExtProd/PRODUCTS && \
                    # some versions for python dependencies have changed.
                    # Also we removed the *bulkDataNT* and *bulkData* modules from the Makefile
                    # as we don't have the properietary version of DDS and don't use this modules.
                    sed -i 's/bulkDataNT bulkData //g' /acs/Makefile && \
                    patch -p1 -d /acs < /tmp/python-module-installation.patch && \
                    source /acs/LGPL/acsBUILD/config/.acs/.bash_profile.acs && \
                    time MAKE_NOSTATIC=1 OPTIMIZE=3 make -C /acs/ExtProd/INSTALL all && \
                    find /alma -name "*.o" -exec rm -v {} \;
# --------------------- Here external dependencies are built --------------

FROM dependency_builder as acs_builder

RUN cd /acs/ && \
    source /acs/LGPL/acsBUILD/config/.acs/.bash_profile.acs && \
    time MAKE_NOSTATIC=1 OPTIMIZE=3 MAKE_PARS="-j $(nproc)" make build && \
    find $ACS_ROOT -name "*.o" -exec rm {} \; && \
    find $ACS_ROOT -type f -executable |grep -v "/pyenv/" | xargs file | grep ELF | awk '{print $1}' | tr -d ':' | xargs strip --strip-unneeded
# ============= Target image stage ===========================================
FROM base

WORKDIR /

COPY --from=acs_builder /alma /alma

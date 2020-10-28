FROM centos:8 AS base
# ================ Builder stage =============================================
# we base our image on a vanilla Centos 8 image.

ARG ACS_VERSION="2020.8"
ENV ACS_VERSION=$ACS_VERSION

ARG ACS_TAG="2020AUG"
ENV ACS_TAG=$ACS_TAG

ENV ACS_PREFIX=/alma
ENV ACS_ROOT="${ACS_PREFIX}/ACS-${ACS_TAG}"

ENV JAVA_HOME="/usr/java/default"

# The package list below is alphabetically sorted, so not sorted by importance.
# It may very well be, that noe all packages are actually needed.
# If you studied this, and found out we can shorten this list without loosing
# the ability to execute all the ACS examples, we'd be happy to hear from you
# either by opening an issue, or by you immediately fixing this and opening a
# pull request.
RUN yum install -y  autoconf \
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
                    openssh-server \
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
    ln -sv /usr/lib/jvm/java-openjdk $JAVA_HOME

# ============= Compiler Stage ===============================================
FROM base AS dependency_builder

COPY acs/ /acs

RUN yum -y install  \
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
    ## Get missing (super old) libraries
    wget https://sourceforge.net/projects/gnuplot-py/files/Gnuplot-py/1.8/gnuplot-py-1.8.tar.gz/download -O gnuplot-py-1.8.tar.gz && \
    wget https://sourceforge.net/projects/pychecker/files/pychecker/0.8.17/pychecker-0.8.17.tar.gz/download -O pychecker-0.8.17.tar.gz && \
    wget https://sourceforge.net/projects/numpy/files/OldFiles/1.3.3/numarray-1.3.3.tar.gz && \
    # some versions for python dependencies have changed.
    # Also we removed the *bulkDataNT* and *bulkData* modules from the Makefile
    # as we don't have the properietary version of DDS and don't use this modules.
    sed -i 's/bulkDataNT bulkData //g' /acs/Makefile && \
    cd /acs/ExtProd/INSTALL && \
    source /acs/LGPL/acsBUILD/config/.acs/.bash_profile.acs && \
    time make all && \
    find /alma -name "*.o" -exec rm {} \;
# --------------------- Here external dependencies are built --------------

FROM dependency_builder as acs_builder

RUN cd /acs/ && \
    source /acs/LGPL/acsBUILD/config/.acs/.bash_profile.acs && \
    time make build

# ============= Target image stage ===========================================
FROM base

WORKDIR /

COPY --from=acs_builder /alma /alma

RUN ln -sv $ACS_ROOT/ACSSW/config/.acs/.bash_profile.acs /alma

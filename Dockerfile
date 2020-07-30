FROM centos:7  AS  builder
# ================ Builder stage =============================================
# we base our image on a vanilla Centos 7 image.

# install deltarpm prior to installing everything else
# it might save some time during downloading and installing the
# dependencies below, but it is not urgently needed for ACS to work
# c.f. https://www.cyberciti.biz/faq/delta-rpms-disabled-because-applydeltarpm-not-installed/
RUN yum update -y && yum install -y deltarpm && \


# The package list below is alphabetically sorted, so not sorted by importance.
# It may very well be, that noe all packages are actually needed.
# If you studied this, and found out we can shorten this list without loosing
# the ability to execute all the ACS examples, we'd be happy to hear from you
# either by opening an issue, or by you immediately fixing this and opening a
# pull request.
	yum -y install epel-release && \
	yum -y groupinstall "Development Tools" && \
  	yum -y install  autoconf \
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

# ============= Compiler Stage ===============================================
FROM builder AS compiler

COPY patches/ /acs_patches_delete_me

RUN time git clone https://bitbucket.alma.cl/scm/asw/acs.git /acs && \
	cd /acs && \
	time git checkout release/OFFLINE-2020APR-B && \
	cd ExtProd/PRODUCTS && \

## Get missing (super old) libraries
wget https://sourceforge.net/projects/gnuplot-py/files/Gnuplot-py/1.8/gnuplot-py-1.8.tar.gz/download -O gnuplot-py-1.8.tar.gz && \
wget https://sourceforge.net/projects/pychecker/files/pychecker/0.8.17/pychecker-0.8.17.tar.gz/download -O pychecker-0.8.17.tar.gz && \
wget https://sourceforge.net/projects/numpy/files/OldFiles/1.3.3/numarray-1.3.3.tar.gz && \

# some versions for python dependencies have changed.
# Also we removed the *bulkDataNT* and *bulkData* modules from the Makefile
# as we don't have the properietary version of DDS and don't use this modules.


	patch --verbose /acs/ExtProd/PRODUCTS/acs-py27.req < /acs_patches_delete_me/acs-py27.req.patch && \
	patch --verbose /acs/ExtProd/PRODUCTS/acs-py37.req < /acs_patches_delete_me/acs-py37.req.patch && \
	patch --verbose /acs/Makefile < /acs_patches_delete_me/Makefile.patch && \
	rm -r /acs_patches_delete_me && \
	cd /acs/ExtProd/INSTALL && \
# --------------------- Here external dependencies are built --------------
	source /acs/LGPL/acsBUILD/config/.acs/.bash_profile.acs && \
    export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.7.10-4.el7_8.x86_64 && \
    time make all && \
    find /alma -name "*.o" -exec rm -v {} \; && \

# Expected output:
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

# So it is okay if `buildAnd` fails. You can check the `buildAnt.log` ..
# and you will see, that the build is actually fine, just some tests do not succeed.

# --------------------- Here ACS is build. --------------------------------

	cd /acs && \
	source /acs/LGPL/acsBUILD/config/.acs/.bash_profile.acs && \
    export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.7.10-4.el7_8.x86_64 && \
    time make
# Expected output:
# Evaluating current ACS TAG from https://bitbucket.alma.cl/scm/asw/acs.git
# REPO tag is: release/OFFLINE-2020APR-B
############ Clean Build Log File: build.log #################
############ Check directory tree for modules  #################
############ Prepare installation areas      #################
############ (Re-)build ACS Software         #################
############ LGPL/Kit/doc SRC
############ LGPL/Kit/acs SRC
############ LGPL/Kit/acstempl SRC
############ LGPL/Kit/acsutilpy SRC
############ LGPL/Tools MAIN
  ############ (Re-)build Tools Software         #################
  ############ tat MAIN
  ############ expat WS
  ############ loki WS
  ############ extjars MAIN
  ############ antlr MAIN
  ############ hibernate MAIN
  ############ extpy MAIN
  ############ cppunit MAIN
  ############ getopt MAIN
  ############ astyle MAIN
  ############ xercesc MAIN
  ############ xercesj MAIN
  ############ castor MAIN
  ############ xsddoc MAIN
  ############ extidl WS
  ############ vtd-xml MAIN
  ############ oAW MAIN
  ############ shunit2 MAIN
  ############ log4cpp WS
  ############ scxml_apache MAIN
  ############ DONE (Re-)build Tools Software    #################
############ LGPL/CommonSoftware/jacsutil SRC
############ LGPL/CommonSoftware/xmljbind SRC
############ LGPL/CommonSoftware/xmlpybind SRC
############ LGPL/CommonSoftware/acserridl WS
############ LGPL/CommonSoftware/acsidlcommon WS
############ LGPL/CommonSoftware/acsutil WS
############ LGPL/CommonSoftware/acsstartup SRC
############ LGPL/CommonSoftware/loggingidl WS
############ LGPL/CommonSoftware/logging WS
############ LGPL/CommonSoftware/acserr WS
############ LGPL/CommonSoftware/acserrTypes WS
############ LGPL/CommonSoftware/acsQoS WS
############ LGPL/CommonSoftware/acsthread WS
############ LGPL/CommonSoftware/acscomponentidl WS
############ LGPL/CommonSoftware/cdbidl WS
############ LGPL/CommonSoftware/maciidl WS
############ LGPL/CommonSoftware/baciidl WS
############ LGPL/CommonSoftware/acsncidl WS
############ LGPL/CommonSoftware/acsjlog SRC
############ LGPL/CommonSoftware/repeatGuard WS
############ LGPL/CommonSoftware/loggingts WS
############ LGPL/CommonSoftware/loggingtsTypes WS
############ LGPL/CommonSoftware/jacsutil2 SRC
############ LGPL/CommonSoftware/cdb WS
############ LGPL/CommonSoftware/cdbChecker SRC
############ LGPL/CommonSoftware/codegen SRC
############ LGPL/CommonSoftware/cdb_rdb SRC
############ LGPL/CommonSoftware/acsalarmidl WS
############ LGPL/CommonSoftware/acsalarm SRC
############ LGPL/CommonSoftware/acsContainerServices WS
############ LGPL/CommonSoftware/acscomponent WS
############ LGPL/CommonSoftware/recovery WS
############ LGPL/CommonSoftware/basenc WS
############ LGPL/CommonSoftware/archiveevents WS
############ LGPL/CommonSoftware/parameter SRC
############ LGPL/CommonSoftware/baci WS
############ LGPL/CommonSoftware/enumprop WS
############ LGPL/CommonSoftware/acscallbacks SRC
############ LGPL/CommonSoftware/acsdaemonidl WS
############ LGPL/CommonSoftware/jacsalarm SRC
############ LGPL/CommonSoftware/jmanager SRC
############ LGPL/CommonSoftware/maci WS
############ LGPL/CommonSoftware/task SRC
############ LGPL/CommonSoftware/acstime WS
############ LGPL/CommonSoftware/acsnc WS
############ LGPL/CommonSoftware/acsdaemon WS
############ LGPL/CommonSoftware/acslog WS
############ LGPL/CommonSoftware/acstestcompcpp SRC
############ LGPL/CommonSoftware/acsexmpl WS
############ LGPL/CommonSoftware/jlogEngine SRC
############ LGPL/CommonSoftware/acspycommon SRC
############ LGPL/CommonSoftware/acsalarmpy SRC
############ LGPL/CommonSoftware/acspy SRC
############ LGPL/CommonSoftware/comphelpgen SRC
############ LGPL/CommonSoftware/XmlIdl SRC
############ LGPL/CommonSoftware/define WS
############ LGPL/CommonSoftware/acstestentities SRC
############ LGPL/CommonSoftware/jcont SRC
############ LGPL/CommonSoftware/jcontnc SRC
############ LGPL/CommonSoftware/nsStatisticsService SRC
############ LGPL/CommonSoftware/jacsalarmtest SRC
############ LGPL/CommonSoftware/jcontexmpl SRC
############ LGPL/CommonSoftware/jbaci SRC
############ LGPL/CommonSoftware/monitoring MAIN
  ############ (Re-)build monitoring Software         #################
  ############ monicd WS
  ############ moncollect WS
  ############ monblobber MAIN
  ############ moncontroller MAIN
  ############ DONE (Re-)build monitoring Software    #################
############ LGPL/CommonSoftware/acssamp WS
# ... tbc


# ============= Target image stage ===========================================
FROM builder

WORKDIR /

COPY --from=compiler /alma /alma

# Here we create the user almamgr
RUN  groupadd -g 1000 almamgr && \
     useradd -g 1000 -u 1000 -d /home/almamgr -m -s /bin/bash almamgr && \
     passwd -d almamgr && \
# For conveniece we source the alma .bash_profile.acs in the user .bash_rc
# and export JAVA_HOME
     echo "source /alma/ACS-2020APR/ACSSW/config/.acs/.bash_profile.acs" >> /home/almamgr/.bashrc && \
	 echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.7.10-4.el7_8.x86_64" >> /home/almamgr/.bashrc && \


# Here we make sure, that sshd is setup correctly. Using sshd is a docker anti-pattern
# but for simplicity we do it nevertheless.
# NOTE! We allow empty passwords.
     sed "s@#X11UseLocalhost yes@X11UseLocalhost no@g" -i /etc/ssh/sshd_config && \
     sed "s@#UseDNS yes@UseDNS no@g" -i /etc/ssh/sshd_config && \
     sed "s@#PermitEmptyPasswords no@PermitEmptyPasswords yes@g" -i /etc/ssh/sshd_config && \
# sshd needs these keys to be created.
     /usr/bin/ssh-keygen -A

# We tell docker, that we plan to expost port 22 - the default SSH port.
# With: docker run -dP   docker decides which port to use on the host
# With: docker run -d -p 10022:22  we decided that port 22 should be exposed as 10022.
# Both variants have their use cases.
EXPOSE 22

# As a last step we, we start the SSH daemon.
CMD ["/usr/sbin/sshd", "-D"]

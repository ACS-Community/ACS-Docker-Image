# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
export ORIG_MANPATH=$MANPATH
export ORIG_LD_LIBRARY_PATH=$LD_LIBRARY_PATH
export ORIG_PATH=$PATH
export ORIG_PYTHONPATH=$PYTHONPATH
export ORIG_CLASSPATH=$CLASSPATH

export LANG=en_US.utf-8
export LC_ALL=en_US.utf-8

export JAVA_HOME=/usr/lib/jvm/java/
export ACS_RETAIN=1

export INTROOT=${HOME}/INTROOT
export ACSDATA=${HOME}/ACSDATA
export ACS_CDB=${HOME}/CDB

export CLASSPATH=$CLASSPATH:$INTROOT/lib/
export IDL_PATH="$IDL_PATH -I$INTROOT/idl"
. /alma/ACS-JUN2017/ACSSW/config/.acs/.bash_profile.acs

function deactivate_acs_environment() {
  export MANPATH=$ORIG_MANPATH
  export LD_LIBRARY_PATH=$ORIG_LD_LIBRARY_PATH
  export PATH=$ORIG_PATH
  export PYTHONPATH=$ORIG_PYTHONPATH
  export CLASSPATH=$ORIG_CLASSPATH
}


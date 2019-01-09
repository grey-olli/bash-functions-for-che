#!/bin/bash

#outputredirect=" 2>&1 3>&1 |tee -a ${log}"

# check we're allowed to run sudo with each of commands passed to this function as parameter
# typical usage: check_sudo_access cmd1 cmd2 ... cmdN
function check_sudo_access() {
 sudo_cmds="${@}"
 eval "echo \"  Checking we've access to sudo for utils we use it with..\"" $outputredirect
 for cmd in $sudo_cmds ; do 
  cmd_path=`which $cmd`
  sudo -nl $cmd_path >/dev/null 2>/dev/null 3>/dev/null
  retc=$?
  if [ "${retc}" != "0" ]; then
   eval "echo -e \"\\\n`basename ${0}`: Looks like we are not allowed to run '${cmd_path}' with sudo.\\\nAbort.\\\n\"" $outputredirect
   eval "echo \"'sudo' in '${0}' is used in non-interactive mode & thus cannot ask password.\"" $outputredirect
   eval "echo -e \"Note, if you run '${0}' script interactively & know root password:\\\n\\\n run 'sudo ls' (or other allowed cmd) and then rerun `basename ${0}`.\\\n\"" $outputredirect
   eval "echo \"This is needed due to 'sudo' doesn't ask password if it was provided within little timeout earlier.\"" $outputredirect
   exit 2
  fi
 done
}

# Abort if one of these is not present in $PATH
function check_deps() {
 dependencies="${@}"
 eval "echo \"  Checking required dependencies are available..\"" $outputredirect
 for what in $dependencies ; do
  unalias $what >/dev/null 2>/dev/null
  which $what 2>/dev/null >/dev/null
  retc=$?
  if [ "${retc}" != "0" ]; then
   eval "echo -e \"\\\n${0}: ERROR: Requred '\"${what}\"' utility not found. Abort.\"" $outputredirect
   exit 3
  fi
 done
}

# Abort if one of these is not present or not readable on disk
function check_files_readable() {
 local file_list="${@}"
 eval "echo \"Checking required files are available..\"" $outputredirect
 for what in ${file_list} ; do
  if [[ ! -r "$what" ]]; then
   eval "echo -e \"\\\n${0}: ERROR: Requred \"${what}\" not readable or absent. Abort.\"" $outputredirect
   exit 3
  fi
 done
}


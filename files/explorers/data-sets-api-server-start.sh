#!/bin/sh
#######################################################################
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License v2.0 which
# accompanies this distribution, and is available at
# https://www.eclipse.org/legal/epl-v20.html
#
# SPDX-License-Identifier: EPL-2.0
#
# Copyright Contributors to the Zowe Project. 2018, 2019
#######################################################################

#% Start **SERVER_NAME**.
#%
#% Invocation arguments:
#% -?            show this help message
#% -c zowe.yaml  start server using the specified input file
#% -d            enable debug messages
#%
#% If -c is not specified, then the server is started using default
#% values.

# Called by zowe-run.sh
#
# Expected globals:
# $IgNoRe_ErRoR $debug $INSTALL_DIR

keyStore=api-mediation/keystore/localhost/localhost.keystore.p12
keyStorePassword=password
keyStoreType=PKCS12
keyAlias=localhost

here=$(dirname $0)             # script location
me=$(basename $0)              # script name
#debug=-d                      # -d or null, -d triggers early debug
#IgNoRe_ErRoR=1                # no exit on error when not null  #debug
#set -x                                                          #debug

test "$debug" && echo "> $me $@"

# ---------------------------------------------------------------------
# --- show & execute command, and bail with message on error
#     stderr is routed to stdout to preserve the order of messages
# $1: if --null then trash stdout, parm is removed when present
# $1: if --save then append stdout to $2, parms are removed when present
# $1: if --repl then save stdout to $2, parms are removed when present
# $2: if $1 = --save or --repl then target receiving stdout
# $@: command with arguments to execute
# ---------------------------------------------------------------------
function _cmd
{
test "$debug" && echo
if test "$1" = "--null"
then         # stdout -> null, stderr -> stdout (without going to null)
  shift
  test "$debug" && echo "$@ 2>&1 >/dev/null"
                         $@ 2>&1 >/dev/null
elif test "$1" = "--save"
then         # stdout -> >>$2, stderr -> stdout (without going to $2)
  sAvE=$2
  shift 2
  test "$debug" && echo "$@ 2>&1 >> $sAvE"
                         $@ 2>&1 >> $sAvE
elif test "$1" = "--repl"
then         # stdout -> >$2, stderr -> stdout (without going to $2)
  sAvE=$2
  shift 2
  test "$debug" && echo "$@ 2>&1 > $sAvE"
                         $@ 2>&1 > $sAvE
else         # stderr -> stdout, caller can add >/dev/null to trash all
  test "$debug" && echo "$@ 2>&1"
                         $@ 2>&1
fi    #
sTaTuS=$?
if test $sTaTuS -ne 0
then
  echo "** ERROR $me '$@' ended with status $sTaTuS"
  test ! "$IgNoRe_ErRoR" && exit 8                               # EXIT
fi    #
}    # _cmd

# ---------------------------------------------------------------------
# --- display script usage information
# ---------------------------------------------------------------------
function _displayUsage
{
echo " "
echo " $(basename $0)"
sed -n 's/^#%//p' $(whence $0)
echo " "
}    # _displayUsage

# ---------------------------------------------------------------------
# --- main --- main --- main --- main --- main --- main --- main ---
# ---------------------------------------------------------------------
function main { }     # dummy function to simplify program flow parsing
export _EDC_ADD_ERRNO2=1                        # show details on error

echo
echo "-- $me -- $(sysvar SYSNAME) -- $(date)"
echo "-- startup arguments: $@"

# Clear input variables
# do NOT unset debug ZOWE_CFG

# Get startup arguments
while getopts c:d? opt
do case "$opt" in
  c)   export ZOWE_CFG="$OPTARG";;
  d)   export debug="-d";;
  [?]) _displayUsage
       test $opt = '?' || echo "** ERROR $me faulty startup argument: $@"
       test ! "$IgNoRe_ErRoR" && exit 8;;                        # EXIT
  esac    # $opt
done    # getopts
shift $OPTIND-1

# No install/configuration, only runtime (used by zowe-set-envvars.sh)
unset inst conf

# Set environment variables when not called via zowe-run.sh
if test -z "$INSTALL_DIR"
then
  # Note: script exports environment vars, so run in current shell
  _cmd . $here/zowe-scripts/zowe-set-envvars.sh $0
fi    #

# Get server name based on startup script name
name=${me%%-api-server*}     # keep up to first -api-server (exclusive)

# Get name of server jar (assumes this script is 1 directory deeper)
serverJar=$(ls -t $here/../${name}-api-server-*.jar | head -1) 2>&1
if test ! -f $serverJar
then
  echo "** ERROR $me $name API (${name}-api-server-*.jar) missing"
  echo "ls -l \"$here/..\""; ls -l "$here/.."
  test ! "$IgNoRe_ErRoR" && exit 8                               # EXIT
fi    #

# Verify that Java is available
if test ! -x "$JAVA_HOME/bin/java"
then
  echo "** ERROR $me cannot execute '$JAVA_HOME/bin/java'"
  echo "ls -l \"$JAVA_HOME/bin/\""; ls -l "$JAVA_HOME/bin/"
  test ! "$IgNoRe_ErRoR" && exit 8                               # EXIT
fi    #

# Prefix PATH with our Java location to ensure we invoke the right one
# Prefix PATH with $here to allow for backdoor overrides
export PATH=$here:$JAVA_HOME/bin:$PATH
test "$debug" && echo "PATH=$PATH"

# Start server
echo "Starting server $(date)..."
options="-Xms16m -Xmx512m \
  -Xquickstart \
  -Dibm.serversocket.recover=true \
  -Dfile.encoding=UTF-8 \
  -Djava.io.tmpdir=${TMPDIR:-/tmp} \
  -Dserver.port=${**SERVER_PORT**} \
  -Dserver.ssl.keyAlias=${keyAlias} \
  -Dserver.ssl.keyStore=${ZOWE_ROOT_DIR}/${keyStore} \
  -Dserver.ssl.keyStorePassword=${keyStorePassword} \
  -Dserver.ssl.keyStoreType=${keyStoreType} \
  -Dzosmf.httpsPort=${ZOWE_ZOSMF_PORT} \
  -Dzosmf.ipAddress=${ZOWE_IPADDRESS} \
  -jar ${serverJar}"
test "$debug" && echo "java $options &"
java $options &
rc=$?

test "$debug" && echo "< $me $rc"
exit $rc

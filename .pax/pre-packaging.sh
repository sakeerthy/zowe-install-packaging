#!/bin/sh -e
set -x

################################################################################
# This program and the accompanying materials are made available under the terms of the
# Eclipse Public License v2.0 which accompanies this distribution, and is available at
# https://www.eclipse.org/legal/epl-v20.html
#
# SPDX-License-Identifier: EPL-2.0
#
# Copyright IBM Corporation 2018, 2019
################################################################################

CURRENT_PWD=$(pwd)
SCRIPT_NAME=$(basename "$0")
ZOWE_VERSION=$(cat content/version)

################################################################################
if [ -z "$ZOWE_VERSION" ]; then
  echo "[$SCRIPT_NAME] ZOWE_VERSION environment variable is missing"
  exit 1
else
  echo "[$SCRIPT_NAME] working on Zowe v${ZOWE_VERSION} ..."
  # remove the version file
  rm content/version
fi

################################################################################
echo "[$SCRIPT_NAME] creating smpe.pax ..."
cd content/zowe-$ZOWE_VERSION/files/smpe
pax -w -f "${CURRENT_PWD}/smpe.pax" *
cd ..
rm -fr smpe
cd "$CURRENT_PWD"


################################################################################
echo "[$SCRIPT_NAME] creating admin.pax ..."
cd content/zowe-$ZOWE_VERSION/files/admin
pax -w -f ../admin.pax *
cd ..
rm -fr admin
cd "$CURRENT_PWD"


################################################################################
echo "[$SCRIPT_NAME] moving smpe bld folder ..."
mv content/zowe-$ZOWE_VERSION/files/bld "$CURRENT_PWD"


################################################################################
echo "[$SCRIPT_NAME] creating apiml pax ..."
# Create mediation PAX
cd mediation
pax -x os390 -w -f ../content/zowe-$ZOWE_VERSION/files/api-mediation-package-0.8.4.pax *
cd ..

# Cleanup working files
rm -rf mediation
rm -f mediation.tar


################################################################################
echo "[$SCRIPT_NAME] processing zss.pax ..."
# extract zss.pax
mkdir -p content/zowe-$ZOWE_VERSION/files/zss
cd content/zowe-$ZOWE_VERSION/files/zss
pax -r -px -f ../zss.pax
rm ../zss.pax
[ -f "SAMPLIB/ZWESIS01" ] && rm SAMPLIB/ZWESIS01
[ -f "SAMPLIB/ZWESISMS" ] && rm SAMPLIB/ZWESISMS
cd "$CURRENT_PWD"


################################################################################
# FIXME: smpe doesn't need this config file? or should be somewhere else?
rm content/zowe-$ZOWE_VERSION/install/zowe-install.yaml


################################################################################
echo "[$SCRIPT_NAME] overwrite explorers start scripts ..."
mkdir -p content/zowe-$ZOWE_VERSION/files/scripts
cp content/zowe-$ZOWE_VERSION/files/explorers/data-sets-api-server-start.sh content/zowe-$ZOWE_VERSION/files/scripts
cp content/zowe-$ZOWE_VERSION/files/explorers/jobs-api-server-start.sh content/zowe-$ZOWE_VERSION/files/scripts
cp content/zowe-$ZOWE_VERSION/files/explorers/start-explorer-jes-ui-server.sh content/zowe-$ZOWE_VERSION/jes_explorer/scripts
cp content/zowe-$ZOWE_VERSION/files/explorers/start-explorer-mvs-ui-server.sh content/zowe-$ZOWE_VERSION/mvs_explorer/scripts
cp content/zowe-$ZOWE_VERSION/files/explorers/start-explorer-uss-ui-server.sh content/zowe-$ZOWE_VERSION/uss_explorer/scripts
rm -fr content/zowe-$ZOWE_VERSION/files/explorers


################################################################################
echo "[$SCRIPT_NAME] change scripts to be executable ..."
chmod +x content/zowe-$ZOWE_VERSION/scripts/*.sh
chmod +x content/zowe-$ZOWE_VERSION/scripts/opercmd_delete
chmod +x content/zowe-$ZOWE_VERSION/scripts/ocopyshr.clist
chmod +x content/zowe-$ZOWE_VERSION/install/*.sh

#!/bin/sh -e
set -x

################################################################################
# This program and the accompanying materials are made available under the terms of the
# Eclipse Public License v2.0 which accompanies this distribution, and is available at
# https://www.eclipse.org/legal/epl-v20.html
#
# SPDX-License-Identifier: EPL-2.0
#
# Copyright IBM Corporation 2019
################################################################################

FUNC=[CreatePax][post-packaging]
CURRENT_PWD=$(pwd)
INPUT_TXT=input.txt

# display extracted files
echo "$FUNC content of $CURRENT_PWD...."
find . -print

# find zowe pax
ZOWE_PAX=$(ls -1 zowe-*.pax | grep -v smpe)
if [ -z "${ZOWE_PAX}" ]; then
  echo "Cannot find Zowe package."
  exit 1
fi
# find zowe cli
ZOWE_CLI=$(ls -1 zowe-cli-*.zip)
if [ -z "${ZOWE_CLI}" ]; then
  echo "Cannot find Zowe CLI package."
  exit 2
fi
echo "$FUNC Zowe package is: ${ZOWE_PAX}"
echo "$FUNC Zowe CLI package is: ${ZOWE_CLI}"

SMPE_PAX=smpe.pax
if [ ! -f "${SMPE_PAX}" ]; then
  echo "$FUNC smpe.pax is not created."
  exit 10
fi

echo "$FUNC pareparing ${INPUT_TXT} ..."
echo "${CURRENT_PWD}/${ZOWE_PAX}" > "${INPUT_TXT}"
echo "${CURRENT_PWD}/${ZOWE_CLI}" >> "${INPUT_TXT}"
echo "${CURRENT_PWD}/${SMPE_PAX}" >> "${INPUT_TXT}"
echo "$FUNC content of ${INPUT_TXT}:"
cat "${INPUT_TXT}"
mkdir -p zowe

# run smpe.sh
#  -a "${CURRENT_PWD}/bld/_alter.sh" \
# ./bld/smpe.sh \
#   -i "${CURRENT_PWD}/${INPUT_TXT}" \
#   -v 120 \
#   -r "${CURRENT_PWD}/zowe"

echo "Manually run: ${CURRENT_PWD}# ./bld/smpe.sh -i \"${CURRENT_PWD}/${INPUT_TXT}\" -v 120 -r \"${CURRENT_PWD}/zowe\""

# exit for manual processing
exit 1

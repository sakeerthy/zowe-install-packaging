#!/bin/sh
#
# build smpe.pax
#
root=$(dirname $0) ; cd $root ; root=$PWD

echo "set stage"
chmod 755 $(find $root/_new -level 0 -type f) 2>&1
chtag -r  $(find $root/_new -level 0 -type f) 2>&1
rm -r $root/_new/tmp 2>/dev/null

rm -r $root/_new/pax/smpe.pax 2>/dev/null
mkdir -p $root/_new/pax 2>&1
mkdir -p $root/_new/tmp 2>&1
cd $root/_new/tmp 2>&1

echo "rebuild"
mkdir -p MVS 2>&1
mkdir -p USS 2>&1
mkdir -p scripts 2>&1
cp ../ZWE[[:digit:]]* ../ZWEMKDIR.rex MVS/ 2>&1
cp ../ZWES[[:digit:]]* MVS/ 2>&1
cp ../ZWESHPAX.sh USS/ 2>&1
cp ../allocate-dataset.sh ../check-dataset-exist.sh \
   ../check-dataset-dcb.sh scripts 2>&1
cp ../smpe-members.sh . 2>&1

echo "create pax"
pax -w -f ../pax/smpe.pax -s#$(pwd)## -o saveext -px $(ls -A) 2>&1

echo "cleanup"
cd $root/_new 2>&1
rm -r $root/_new/tmp 2>&1

echo "verify pax"
pax -f pax/smpe.pax 2>&1


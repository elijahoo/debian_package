#!/bin/bash

set -e

release=$1

DEBIAN_DIST=`lsb_release -c | awk '{printf $2}'`
DEBIAN_ROOT=$(pwd -P ${BASH_SOURCE[0]})
DEBIAN_DIR=$DEBIAN_ROOT/$( dirname "${BASH_SOURCE[0]}")
BUILD_FOLDER="$DEBIAN_DIR/build"
REDMINE="redmine-$release"

PUBLISH_LOCATION="admin@app.swissfm.ch:/sfmtool/tmp/update/debian/${DEBIAN_DIST}"

if [[ $release =~ [0-9]\.[0-9]\.[0-9]+$ ]]; then

  echo "clean"
  rm -rf $BUILD_FOLDER && mkdir -p $BUILD_FOLDER

  echo "fetching Redmine from platon"
  rsync -a admin@app.swissfm.ch:/sfmtool/tmp/update/Redmine/Bibliotheken/$REDMINE.tar.gz $DEBIAN_DIR/opt/

  for archive in $DEBIAN_DIR/opt/*.tar.gz; do 
    echo "Extracting $archive ..."; 
    tar xzPf $archive -C $DEBIAN_DIR/opt/
    rm $archive
  done

  echo "copying debian package meta files"
  cp -r ${DEBIAN_DIR}/DEBIAN  ${BUILD_FOLDER}/
  cp -r ${DEBIAN_DIR}/etc  ${BUILD_FOLDER}/
  cp -r ${DEBIAN_DIR}/opt  ${BUILD_FOLDER}/
  cp -r ${DEBIAN_DIR}/var  ${BUILD_FOLDER}/

  echo "remove .DS_Store files"
  find $BUILD_FOLDER -name ".DS_Store" -exec rm {} \;

  echo "Version: ${release}" >> ${BUILD_FOLDER}/DEBIAN/control
  chmod 755 ${BUILD_FOLDER}/DEBIAN/*

  echo "build debian package"
  dpkg-deb -b $BUILD_FOLDER $DEBIAN_ROOT

  built_archive="$DEBIAN_ROOT/sfmredmine_${release}_i386.deb"
  echo "publish '$built_archive' -> '$PUBLISH_LOCATION' ..."
  rsync -aq "$built_archive" "$PUBLISH_LOCATION"

else
  echo "usage: ./build.sh 2.6.10"
  exit -1
fi

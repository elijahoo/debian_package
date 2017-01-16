#!/usr/bin/env bash

set -e

release=$1

DEBIAN_DIST=`lsb_release -c | awk '{printf $2}'`
DEBIAN_ROOT=$(pwd -P ${BASH_SOURCE[0]})
DEBIAN_DIR=$DEBIAN_ROOT/$( dirname "${BASH_SOURCE[0]}")
BUILD_FOLDER="$DEBIAN_DIR/build"
SFMTOOL_BUILD="$BUILD_FOLDER/opt/sfmtool"

PUBLISH_LOCATION="admin@app.swissfm.ch:/sfmtool/tmp/update/debian/$DEBIAN_DIST"

# change to current dir
#cd $( dirname "${BASH_SOURCE[0]}")

if [[ $release =~ ^v[0-9]\.[0-9]\.[0-9]\.[0-9]+$ ]]; then
  # [[ "v3.2.8.0" =~ ^v[0-9]\.[0-9]\.[0-9]\.[0.9]+$ ]] && echo matched

  echo "clean"
  rm -rf $BUILD_FOLDER && mkdir -p $BUILD_FOLDER $SFMTOOL_BUILD/prg

  echo "fetching sfmtool release $release from platon"
  rsync -a admin@app.swissfm.ch:/sfmtool/tmp/update/Tool/Auslieferung/$release/*.tar.gz $SFMTOOL_BUILD/prg/
  rsync -a admin@app.swissfm.ch:/sfmtool/tmp/update/Tool/Auslieferung/$release/*.gem $SFMTOOL_BUILD/prg/

  for archive in $SFMTOOL_BUILD/prg/*.tar.gz; do 
    echo "Extracting $archive ..."; 
    tar xzPf $archive -C $SFMTOOL_BUILD/prg/
    rm $archive
  done

  echo "fetching biblios from platon"
  rsync -a admin@app.swissfm.ch:/sfmtool/tmp/update/Tool/Bibliotheken/* $DEBIAN_DIR/opt/

  for archive in $DEBIAN_DIR/opt/*.tar.gz; do 
    echo "Extracting $archive ..."; 
    tar xzPf $archive -C $DEBIAN_DIR/opt/
    rm $archive
  done

  #echo "git init $SFMTOOL_BUILD/prg/ to track changes"
  git init $SFMTOOL_BUILD/prg/
  echo "./*.gem" > $SFMTOOL_BUILD/prg/.gitignore
  cd $SFMTOOL_BUILD/prg && git add . && git commit --quiet -m "Release $release"

  echo "copying debian package meta files"
  cp -r ${DEBIAN_DIR}/DEBIAN  ${BUILD_FOLDER}/
  cp -r ${DEBIAN_DIR}/etc  ${BUILD_FOLDER}/
  cp -r ${DEBIAN_DIR}/opt  ${BUILD_FOLDER}/
  cp -r ${DEBIAN_DIR}/utils  ${BUILD_FOLDER}/
  cp -r ${DEBIAN_DIR}/home  ${BUILD_FOLDER}/

  echo "remove .DS_Store files"
  find $BUILD_FOLDER -name ".DS_Store" -exec rm {} \;

  # remove first "v" from release and save as version
  echo "Version: ${release:1}" >> ${BUILD_FOLDER}/DEBIAN/control
  chmod 755 ${BUILD_FOLDER}/DEBIAN/*

  echo "build debian package"
  dpkg-deb -b $BUILD_FOLDER $DEBIAN_ROOT

  built_archive="$DEBIAN_ROOT/sfmtool_${release:1}_i386.deb"
  echo "publish '$built_archive' -> '$PUBLISH_LOCATION' ..."
  rsync -aq "$built_archive" "$PUBLISH_LOCATION"

else
  echo "usage: ./build.sh v3.2.8.0"
  exit -1
fi

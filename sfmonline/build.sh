#!/usr/bin/env bash

set -e

release=$1

# DEBIAN_DIST=`lsb_release -c | awk '{printf $2}'`
DEBIAN_DIST="wheezy"
DEBIAN_ROOT=$(pwd -P ${BASH_SOURCE[0]})
DEBIAN_DIR=$DEBIAN_ROOT/$( dirname "${BASH_SOURCE[0]}")
BUILD_FOLDER="$DEBIAN_DIR/build"
SFMONLINE_BUILD="$BUILD_FOLDER/opt/sfmtool/sfmonline"

PUBLISH_LOCATION="app.swissfm.ch:/sfmtool/tmp/update/debian/$DEBIAN_DIST"

# change to current dir
#cd $( dirname "${BASH_SOURCE[0]}")

if [[ $release =~ ^v[0-9]\.[0-9]\.[0-9]\.[0-9]+$ ]]; then
  # [[ "v3.2.8.0" =~ ^v[0-9]\.[0-9]\.[0-9]\.[0.9]+$ ]] && echo matched

  echo "clean"
  rm -rf $BUILD_FOLDER && mkdir -p $BUILD_FOLDER && mkdir -p $SFMONLINE_BUILD

  echo "cloning sfmonline"
  git config --global advice.detachedHead false
  git clone git@app.swissfm.ch:sfmonline.git $SFMONLINE_BUILD --branch $release --single-branch --quiet
  git config --global advice.detachedHead true

  cd $SFMONLINE_BUILD
  mkdir -p log && mkdir -p tmp && chmod 777 tmp && chmod 777 log

  echo "saving git info to $SFMONLINE_BUILD/RELEASE"
  commit=$(git log -n1 --pretty='%h')
  commit_date=$(git log -n1 --pretty='%ai')
  #release=$(git describe --exact-match --tags $commit)
  #tag=$(git rev-parse --short HEAD)

  echo "Release: $release" > RELEASE
  echo "Build: $commit" >> RELEASE
  echo "Date: $commit_date" >> RELEASE
  cat RELEASE

  echo "removing $SFMONLINE_BUILD/.git*"
  rm -rf .git
  rm -f .gitignore

  echo "copying debian package meta files"
  cp -r ${DEBIAN_DIR}/DEBIAN  ${BUILD_FOLDER}/
  cp -r ${DEBIAN_DIR}/etc  ${BUILD_FOLDER}/

  echo "remove .DS_Store files"
  find $BUILD_FOLDER -name ".DS_Store" -exec rm {} \;

  # remove first "v" from release and save as version
  echo "Version: ${release:1}" >> ${BUILD_FOLDER}/DEBIAN/control
  chmod 755 ${BUILD_FOLDER}/DEBIAN/*

  echo "build debian package"
  dpkg-deb -b $BUILD_FOLDER $DEBIAN_ROOT

  built_archive="/tmp/sfmonline_${release:1}_i386.deb"
  echo "publish '$built_archive' -> '$PUBLISH_LOCATION' ..."
  rsync -avq "$built_archive" "$PUBLISH_LOCATION"

else
  echo "usage: ./build.sh v3.2.8.0 "
  exit -1
fi




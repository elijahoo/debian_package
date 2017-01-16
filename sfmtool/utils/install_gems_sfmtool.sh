#!/bin/bash

set -e

DIR_GEM_INTERFACE=/sfmtool/prg/opt/interface
DIR_GEM_NOTIFIER=/sfmtool/prg/fds/bin/notifier
PATH=$PATH:/home/admin/.gem/ruby/1.8/bin

# install kartei, bacnet, etc.
for gem in /sfmtool/prg/*.gem; do
  echo -n "Installing gem $gem ..."
  gem install $gem >/dev/null
  echo " done"
done

# install bundler ...
echo -n "ruby: install bundler ..."
gem install bundler >/dev/null
echo " done"

# bundle install ...
if [ -f "$DIR_GEM_INTERFACE/Gemfile" ] ; then
  echo "installing gems from Gemfile in $DIR_GEM_INTERFACE/ ..."
  cd $DIR_GEM_INTERFACE
  # TODO: fix, cause installation abort!!!
  PATH=$PATH:/home/admin/.gem/ruby/1.8/bin && bundle install
  echo " done"
else
  echo -e "\e[33mno Gemfile found under $DIR_GEM_INTERFACE/\e[0m"
fi

if [ -f "$DIR_GEM_NOTIFIER/Gemfile" ] ; then
  echo "installing gems from Gemfile in $DIR_GEM_NOTIFIER/ ..."
  cd $DIR_GEM_NOTIFIER
  PATH=$PATH:/home/admin/.gem/ruby/1.8/bin && bundle install
  echo " done"
else
  echo -e "\e[33mno Gemfile found under $DIR_GEM_NOTIFIER/\e[0m"
fi

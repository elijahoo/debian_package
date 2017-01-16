#!/bin/bash -e

DIR_GEM_SFMONLINE=/sfmtool/sfmonline

# bundle install ...
if [ -f "$DIR_GEM_SFMONLINE/Gemfile" ] ; then
	echo -n "installing gems from Gemfile in $DIR_GEM_SFMONLINE/ ..."
	su -c "PATH=$PATH:/home/admin/.gem/ruby/1.8/bin" admin
	su -c "cd $DIR_GEM_SFMONLINE" admin
	su -c "bundle install" admin >/dev/null
	echo " done"
else
	echo -e "\e[33mno Gemfile found under $DIR_GEM_SFMONLINE/\e[0m"
fi

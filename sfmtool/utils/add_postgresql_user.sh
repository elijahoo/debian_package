#!/usr/bin/env bash

# check arguments
if [ -n "$1" ];then
  >&2 echo "usage: bash add_postgresql_user.sh <USERNAME> <PASSWORD>"
  exit 1
fi

# add user to postgresql and pg_hba.conf 
POSTGRESQL_USER="$1"
POSTGRESQL_LINE_PG_HBA="local all $POSTGRESQL_USER password"
POSTGRESQL_PG_HBA_FILE=`su -c "psql -t -P format=unaligned -c 'show hba_file';" postgres`

echo "PostgreSQL: create user '$POSTGRESQL_USER' with password ..."
su -c "createuser --no-superuser --no-createrole --pwprompt --encrypted --createdb $POSTGRESQL_USER" postgres

echo "PostgreSQL: add user '$POSTGRESQL_USER' to '$POSTGRESQL_PG_HBA_FILE'"
if ! grep -q "$POSTGRESQL_LINE_PG_HBA" $POSTGRESQL_PG_HBA_FILE ; then
  echo "PostgreSQL: Eintrag noch nicht vorhanden! Eintragen..."
  printf %"s\n" \
      "$POSTGRESQL_LINE_PG_HBA" \
  | sudo tee --append $POSTGRESQL_PG_HBA_FILE
else
  echo "PostgreSQL: Eintrag bereits vorhanden! Ueberspringe..."
fi
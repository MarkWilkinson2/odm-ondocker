#!/bin/bash

set -e

export POSTGRESQL_PASSWORD=${POSTGRES_PASSWORD}

if [ ! -f initialized.flag ] ; then
	if [ "$SAMPLE" = "true" ] ; then
		mkdir -p "$PGDATA"
		cp -R /upload/* "$PGDATA"
	fi;
	touch initialized.flag
fi;

exec "container-entrypoint" "$@"

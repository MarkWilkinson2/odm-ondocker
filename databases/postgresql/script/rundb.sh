#!/bin/bash

set -e

export POSTGRESQL_PASSWORD=${POSTGRES_PASSWORD}

if [ ! -f /tmp/initialized.flag ] ; then
	if [ "$SAMPLE" = "true" ] ; then
		mkdir -p "$PGDATA"
		cp -R /upload/* "$PGDATA"
	fi;
	touch /tmp/initialized.flag
fi;

exec "container-entrypoint" "$@"

#!/bin/sh

cd /var/www/
# if the source already exists, do a pull, otherwise clone it
if cd project; then git pull --ff-only; else git clone ${PROJECT_REPO_URL} project && cd project; fi
# install our project's composer dependencies
composer install --no-interaction --no-dev
ln -s ../.env .env

# any other build scripts that should run on each deploy could be added here

###### copied from default php-fpm entrypoint
set -e

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

##### end of copied section from php-fpm entrypoint

exec "$@"
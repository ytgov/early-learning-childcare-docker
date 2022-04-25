# Docker Configuration for ELCCU Website

This repo contains the docker related items for the ELCCU website. It will create an instance that will clone
the code from a separate repository into the appropriate locations. Configuration values may be set through the .env file

## .env
* DB connection configuration values can be set by copying .env.dist and setting the relevant values. 
* The port apache is exposed on can be configured here.
* The repository URL that should be cloned should be set here as well. The set git repo will be cloned into `/var/www/project/` and apache's document root will point to `/var/www/project/public/`

## docker / docker-compose

The cms and and stack for the site has been containerized using docker. This allows for any developers to have
a consistent environment with the live production deployment reducing the possibility of the "works on my
machine" scenarios.

* the ssh-key for the docker php instance can be set with a command like:
  `docker-compose build --build-arg SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)" --build-arg user=elccu` to copy
  your current user's private key to the docker instance and set the user to elccu. The key is used to access
  the codebase as well as private composer packages.
* docker instance can be brought up running `docker-compose up`
* a .sql dump can be placed in the `./docker-compose/mysql/` directory. When the elccu-website-db container is built this file will be imported into the database

### Persistence

the following folders require persistence between deploys as they are written to by the webserver:
* `project/public/application/files` - files uploaded through the CMS by editors along with cache files reside here
* `project/public/application/config/doctrine` - entity proxy files are stored here - if these are lost they can be regenerated with the command `./vendor/bin/concrete5 c5:entities:refresh`
* `project/public/application/config/generated_overrides` - config settings set through the UI are stored here. These could all be made static and stored in the main config folder with matching files but that limits flexibility for managing the site through the interface

## Webserver

Apache is configured as the webserver from the official php:8.0-apache build, The Dockerfile installs a number of 
additional extensions which are required for concrete-cms to function. An ssh-key should be passed in while building
the instance. The matching public key should be provided access to the main codebase and any required repositories.

A number of changes to the config have been made to prevent *.php from being run. Only the main index.php should be able
to be executed by the webserver.

### Cron Job

A cron job should be set up to run every minute to allow CMS tasks to be automated. This should be set up on the host or in
Kubernetes using something similar to: https://kubernetes.io/docs/tasks/job/automated-tasks-with-cron-jobs/

An example of standard *nix cron syntax would be:

`* * * * * /var/www/project/public/concrete/bin/concrete concrete:scheduler:run >> /dev/null 2>&1`

## Database

The official MySQL 8 docker image is included in the `docker-compose.yml` file however it will likely be connecting to
a shared DB server when launched in production.


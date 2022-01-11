SHELL := /bin/bash

RUBY-VERSION := 3.0.1 # Please write there your needed ruby version
GIT-BACKEND := # Please write there your needed backend git link with ssh or https which using with git clone
GIT-FRONTEND := # Please write there your needed frontend git link with ssh or https which using with git clone
DB-VERSION := # Please write there desired version of PostgreSQL

MACHINE-NAME := $(shell lsb_release -cs)# DO NOT CHANGE THIS LINE, PLEASE! This is name of your OS.
BACK-APP-NAME := $(shell basename $(GIT-BACKEND) .git) # The name of your backend app
FRONT-APP-NAME := $(shell basename $(GIT-FRONTEND) .git) # The name of your frontend app

.DEFAULT_GOAL := installing

installing: check_args packages rvm_rules get_keys get_rvm update_terminal rvm_to_master install_ruby lock_ruby \
	postgres redis check_redis_process download_backend build_backend seeding_of_database
.PHONY: installing

rvm_rules:
	cd makefiles && $(MAKE) -k rvm.mk

check_args:
ifdef DB-ROLE
ifdef DB-VERSION
ifdef GIT-BACKEND
ifdef GIT-FRONTEND
	@echo "Arguments are passed!"
else
	echo "Please fill all args for correcting script work."
	exit 1
endif
endif
endif
endif

packages:
	sudo apt-get install curl g++ gcc autoconf automake bison libpq-dev gpg \
	libc6-dev libffi-dev libgdbm-dev libncurses5-dev libsqlite3-dev dpkg-dev \
	libtool libyaml-dev make pkg-config sqlite3 zlib1g-dev libgmp-dev libreadline-dev libssl-dev

postgres:
ifneq ("$(wildcard /etc/apt/sources.list.d/pgdg.list)","")
	sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(MACHINE-NAME)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
endif
	wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
	-sudo apt-get -y update
	sudo apt-get -y install postgresql-$(DB-VERSION)
	psql --version
	sleep 2

manage_postgres:
	sudo sed -i 's!5433!5432!' /etc/postgresql/$(DB-VERSION)/main/postgresql.conf
	sudo service postgresql restart
	sleep 5
	sudo -u postgres createuser -s -d  $(DB-ROLE)

redis:
	sudo apt-get -y install redis-server

check_redis_process:
	if pgrep -x "redis-server" > /dev/null; then echo "Redis is running"; else echo "Redis does not running! Something happened! Please check redis process sudo systemctl status redis"; exit 1; fi

download_backend:
	cd .. && git clone $(GIT-BACKEND)

build_backend:
	cd ../$(BACK-APP-NAME); cp .env.example .env; bundle && bundle exec rake db:create db:schema:load

seeding_of_database:
	cd ../$(BACK-APP-NAME); bundle exec rake db:seed

-include makefiles/rvm.mk
SHELL := /bin/bash

RUBY-VERSION := 3.0.1 # Please write there your needed ruby version
GIT-BACKEND := # Please write there your needed backend git link with ssh or https which using with git clone
GIT-FRONTEND := # Please write there your needed frontend git link with ssh or https which using with git clone

MACHINE-NAME := $(shell lsb_release -cs)# DO NOT CHANGE THIS LINE, PLEASE! This is name of your OS.
BACK-APP-NAME := $(shell basename $(GIT-BACKEND) .git) # The name of your backend app
FRONT-APP-NAME := $(shell basename $(GIT-FRONTEND) .git) # The name of your frontend app

installing: check_args packages get_keys get_rvm update_terminal rvm_to_master install_ruby lock_ruby postgres redis check_redis_process download_backend build_backend seeding_of_database
.PHONY: installing

check_args:
	if ! [ -s $(DB-ROLE) ] ; then \
		echo "Argument for DB is passed!"; \
	else \
		echo "Please fill DB-ROLE arg for creating db role"; \
		exit 1; \
	fi

packages:
	sudo apt-get install curl g++ gcc autoconf automake bison libpq-dev \
	libc6-dev libffi-dev libgdbm-dev libncurses5-dev libsqlite3-dev dpkg-dev \
	libtool libyaml-dev make pkg-config sqlite3 zlib1g-dev libgmp-dev libreadline-dev libssl-dev

get_keys:
	gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

get_rvm:
	curl -sSL https://get.rvm.io | bash -s stable

update_terminal:
	rvm reload

rvm_to_master:
	rvm get master

install_ruby:
	rvm install $(RUBY-VERSION)

lock_ruby:
	rvm use $(RUBY-VERSION) --default
	ruby -v
	sleep 2

postgres:
	if [ -s /etc/apt/sources.list.d/pgdg.list ]; then \
		sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(MACHINE-NAME)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'; \
	fi
	wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -; \
	sudo apt-get -y update; \
	sudo apt-get -y install postgresql-14; \
	psql --version; \
	sleep 2; \

manage_postgres:
	sudo sed -i 's!5433!5432!' /etc/postgresql/14/main/postgresql.conf
	sudo service postgresql restart
	sleep 5
	sudo -u postgres createuser -s -d  $(DB-ROLE)

redis:
	sudo apt-get -y install redis-server

check_redis_process:
	if pgrep -x "redis-server" > /dev/null; then echo "Redis is running";	else echo "Redis does not running! Something happened! Please check redis process sudo systemctl status redis"; exit 1; fi

download_backend:
	# Если уже есть папка - то нужно избежать ошибки повторного клонирования
	cd .. && git clone $(GIT-BACKEND)

build_backend:
	cd ../$(BACK-APP-NAME); cp .env.example .env; bundle && bundle exec rake db:create db:schema:load

seeding_of_database:
	cd ../$(BACK-APP-NAME); bundle exec rake db:seed

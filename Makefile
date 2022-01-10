RUBY-VERSION := 3.0.1 # Please write there your needed ruby version
GIT-BACKEND := 
GIT-FRONTEND := 

#ARCH := $(shell dpkg-architecture -q DEB_BUILD_ARCH)
MACHINE-NAME := $(shell lsb_release -cs)# DO NOT CHANGE THIS LINE, PLEASE! This is name of your OS.
BACK-APP-NAME := $(shell basename $(GIT-BACKEND) .git) # The name of your backend app
FRONT-APP-NAME := $(shell basename $(GIT-FRONTEND) .git) # The name of your frontend app

installing: packages get_keys get_rvm update_terminal rvm_to_master install_ruby lock_ruby postgres redis check_redis_process download_backend build_backend seeding_of_database
.PHONY: installing

packages:
	sudo apt-get install curl g++ gcc autoconf automake bison \
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

postgres:
	sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(MACHINE-NAME)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
	wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
	-sudo apt-get -y update
	sudo apt-get -y install postgresql
	psql --version

redis:
	sudo apt-get -y install redis-server

check_redis_process:
	if pgrep -x "redis-server" > /dev/null; then echo "Redis is running";	else echo "Redis does not running! Something happened! Please check redis process `sudo systemctl status redis`"; exit 1; fi

download_backend:
	git clone $(GIT-BACKEND)
	cd ../$(BACK-APP-NAME)

build_backend:
	cp .env.example .env
	bundle && bundle exec rake db:create db:load:schema

seeding_of_database:
	bundle exec rake db:seed

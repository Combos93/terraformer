RUBY-VERSION := 3.0.1

installing: packages get_keys get_rvm update_terminal rvm_to_master install_ruby lock_ruby postgres redis check_redis_process
.PHONY: installing

packages:
	sudo apt-get install curl g++ gcc autoconf automake bison \
	libc6-dev libffi-dev libgdbm-dev libncurses5-dev libsqlite3-dev \
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
	sudo apt-get update && sudo apt-get update
	sudo apt-get -y install postgresql postgresql-contrib
	cd ../api/ && bundle && bundle exec rake db:create db:load:schema

redis:
	sudo apt-get -y install redis-server

check_redis_process:
	if pgrep -x "redis-server" > /dev/null; then echo "Redis is running";	else echo "Redis does not running! Something happened! Please check redis process `sudo systemctl status redis`"; exit 1; fi


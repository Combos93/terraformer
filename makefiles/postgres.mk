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

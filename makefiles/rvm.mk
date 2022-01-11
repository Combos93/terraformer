get_keys:
	curl -sSL https://rvm.io/mpapis.asc | gpg --import -
	curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -
#	 TODO: do more secure in the future, because two strings are danger! Add timeout for denied gpg2 connects...
#	gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

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

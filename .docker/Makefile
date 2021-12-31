MAKEFLAGS = $(shell [ "$(debug)" == "true" ] || echo "s" )

db:
	[ -f /etc/apt/sources.list.d/xenial-security.list ] || echo 'deb http://security.ubuntu.com/ubuntu xenial-security main' > /etc/apt/sources.list.d/xenial-security.list
	apt-install build-essential libmysqlclient-dev
	docker-compose up -d db

smtp:
	docker-compose up -d smtp

redis:
	docker-compose up -d redis

nim:
	curl https://nim-lang.org/choosenim/init.sh -sSf | sh

rust:
	apt-install pkg-config
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path

rbenv:
	apt-install autoconf bison build-essential libssl-dev libyaml-dev libreadline-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm-dev libdb-dev
	[ -d ~/.rbenv ] || git clone https://github.com/rbenv/rbenv.git ~/.rbenv
	[ -d ~/.rbenv/plugins/ruby-build ] || git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
	git -C ~/.rbenv pull
	git -C ~/.rbenv/plugins/ruby-build pull

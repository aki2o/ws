MAKEFLAGS = $(shell [ "$(debug)" == "true" ] || echo "s" )

apps_file = .applications
mutagen_file = mutagen.yml

config:
	$(eval cached_app_arg := $(shell [ -f $(apps_file) ] && cat $(apps_file) ))
	$(eval app_arg := $(shell [ "$(remove)" == "true" ] && ruby -e 'puts (%w[$(cached_app_arg)] - %w[$(app)]).sort.uniq.join(" ")' || ruby -e 'puts %w[$(cached_app_arg) $(app)].sort.uniq.join(" ")' ))
	echo $(app_arg) > $(apps_file)
	cp -f ./.files/mutagen.yml $(mutagen_file)
	for app in `cat .applications 2>/dev/null`; do \
	  echo "  $${app}:" >> $(mutagen_file); \
	  echo "    alpha: ./$$app" >> $(mutagen_file); \
	  echo "    beta: aki2o-dev:/usr/src/app/$$app" >> $(mutagen_file); \
	done

ssh_config:
	[ "$(remove)" == "true" ] || vagrant ssh-config > ~/.ssh/config.d/dev
	[ "$(remove)" != "true" ] || rm -f ~/.ssh/config.d/dev 2>/dev/null
	cat ~/.ssh/config.d/* > ~/.ssh/config

up:
	$(eval vm_status := $(shell vagrant status --machine-readable | grep ,state, | awk -F, '{print $$4}'))
	if [ "$(vm_status)" == "not_created" ]; then \
	  VAGRANT_SSH_USER=vagrant vagrant up && vagrant reload; \
	  $(MAKE) ssh_config; \
	elif [ "$(vm_status)" == "poweroff" -a "$(provision)" == "true" ]; then \
	  VAGRANT_SSH_USER=vagrant vagrant up --provision && vagrant reload; \
	  $(MAKE) ssh_config; \
	elif [ "$(vm_status)" == "poweroff" ]; then \
	  vagrant up; \
	  $(MAKE) ssh_config; \
	elif [ "$(provision)" == "true" ]; then \
	  VAGRANT_SSH_USER=vagrant vagrant provision; \
	fi
	if [ "$(vm_status)" == "not_created" -o "$(vm_status)" == "poweroff" ]; then \
	  $(MAKE) mutagen_start; \
	  echo -n "ファイルを同期しています..."; \
	  waitings=0; \
	  while [ $$waitings -lt 300 ]; do \
	    mutagen sync list | grep Status | grep -v 'Watching for changes' >/dev/null; \
	    [ $$? -ne 0 ] && break; \
	    sleep 5; \
	    echo -n "."; \
	    waitings=`expr $$waitings + 5`; \
	  done; \
	  echo ""; \
	  [ $$waitings -lt 300 ] || (mutagen sync list && echo -e "\nWarning: ファイル同期が完了していません！\nWarning: この後の作業に支障があるかもしれません。出力されている同期状況を確認してください"); \
	fi
	vagrant ssh -c "cd /usr/src/docker; bash -l"

down:
	mutagen project terminate -f mutagen.yml 2>/dev/null
	vagrant halt
	$(MAKE) ssh_config remove=true

clean:
	vagrant destroy -f

mutagen_start:
	mutagen project terminate -f mutagen.yml 2>/dev/null; \
	mutagen daemon stop 2>/dev/null; \
	mutagen project start -f mutagen.yml

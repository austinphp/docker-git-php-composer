# --------------------------------------------------------------------
# Copyright (c) 2019 LINKIT, The Netherlands. All Rights Reserved.
# Author(s): Anthony Potappel
# 
# This software may be modified and distributed under the terms of the
# MIT license. See the LICENSE file for details.
# --------------------------------------------------------------------

# If you see pwd_unknown showing up, this is why. Re-calibrate your system.
PWD ?= pwd_unknown

# PROJECT_NAME defaults to name of the current directory.
# should not to be changed if you follow GitOps operating procedures.
PROJECT_NAME = docker-git-php-composer

# Note. If you change this, you also need to update docker-compose.yml.
# only useful in a setting with multiple services/ makefiles.
SERVICE_TARGET = latest

export PROJECT_NAME
export SERVICE_TARGET

# all our targets are phony (no files to check).
.PHONY: shell help build rebuild service login test clean prune

# suppress makes own output
#.SILENT:

# shell is the first target. So instead of: make shell cmd="whoami", we can type: make cmd="whoami".
# more examples: make shell cmd="whoami && env", make shell cmd="echo hello container space".
# leave the double quotes to prevent commands overflowing in makefile (things like && would break)
# special chars: '',"",|,&&,||,*,^,[], should all work. Except "$" and "`", if someone knows how, please let me know!).
# escaping (\) does work on most chars, except double quotes (if someone knows how, please let me know)

# i.e. works on most cases. For everything else perhaps more useful to upload a script and execute that.

shell:
ifeq ($(CMD_ARGUMENTS),)
	# no command is given, default to shell
	docker-compose -p $(PROJECT_NAME) run --rm $(SERVICE_TARGET) sh
else
	# run the command
	docker-compose -p $(PROJECT_NAME) run --rm $(SERVICE_TARGET) sh -c "$(CMD_ARGUMENTS)"
endif

# Regular Makefile part for buildpypi itself
help:
	@echo ''
	@echo 'Usage: make [TARGET] [EXTRA_ARGUMENTS]'
	@echo 'Targets:'
	@echo '  build      build docker --image--'
	@echo '  rebuild    rebuild docker --image--'
	@echo '  test       test docker --container--'
	@echo '  service    run as service --container--'
	@echo '  login      run as service and login --container--'
	@echo '  clean      remove docker --image--'
	@echo '  prune      shortcut for docker system prune -af. Cleanup inactive containers and cache.'
	@echo '  shell      run docker --container--'
	@echo ''
	@echo 'Extra arguments:'
	@echo 'cmd=:    make cmd="whoami"'

rebuild:
    # force a rebuild by passing --no-cache
	docker-compose build --no-cache $(SERVICE_TARGET)

service:
	# run as a (background) service
	docker-compose -p $(PROJECT_NAME) up -d $(SERVICE_TARGET)

login: service
	# run as a service and attach to it
	docker exec -it $(PROJECT_NAME) sh

build:
	# only build the container. Note, docker does this also if you apply other targets.
	docker-compose build $(SERVICE_TARGET)
	docker-compose build 'focal-php7.3-phpunit7.5.8'
	docker-compose build 'focal-php7.3-phpunit8.5.5'
	docker-compose build 'focal-php7.4-phpunit7.5.8'
	docker-compose build 'focal-php7.4-phpunit8.5.5'
	docker-compose build 'focal-php7.4-phpunit9.2.1'
	docker-compose build 'xenial-php7.3-phpunit7.5.8'
	docker-compose build 'xenial-php7.4-phpunit8.5.5'
	docker-compose build 'xenial-php7.4-phpunit9.2.1'

clean:
	# remove created images
	@docker-compose -p $(PROJECT_NAME) down --remove-orphans --rmi all 2>/dev/null \
	&& echo 'Image(s) for "$(PROJECT_NAME)" removed.' \
	|| echo 'Image(s) for "$(PROJECT_NAME)" already removed.'

prune:
	# clean all that is not actively used
	docker system prune -af

test:
	# here it is useful to add your own customised tests
	docker-compose -p $(PROJECT_NAME) run --rm $(SERVICE_TARGET) sh -c '\
		echo "I am `whoami`. My uid is `id -u`." && echo "Docker runs!"' \
	&& echo success

push:
	docker push austinphp/docker-git-php-composer:latest
	docker push austinphp/docker-git-php-composer:focal-php7.3-phpunit7.5.8
	docker push austinphp/docker-git-php-composer:focal-php7.3-phpunit8.5.5
	docker push austinphp/docker-git-php-composer:focal-php7.4-phpunit7.5.8
	docker push austinphp/docker-git-php-composer:focal-php7.4-phpunit8.5.5
	docker push austinphp/docker-git-php-composer:focal-php7.4-phpunit9.2.1
	docker push austinphp/docker-git-php-composer:xenial-php7.3-phpunit7.5.8
	docker push austinphp/docker-git-php-composer:xenial-php7.4-phpunit8.5.5
	docker push austinphp/docker-git-php-composer:xenial-php7.4-phpunit9.2.1

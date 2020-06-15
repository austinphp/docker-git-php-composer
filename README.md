
# docker-git-php-composer

These Docker images are a good starting point for deployment, worker or service containers that need php support. It is a great base image to run unit tests and/or do your deployments. We use ubuntu as the base image but will consider adding support for other base images in the future. Please consider using a different repo for your production application base image.

We use ```make``` to build all the docker images. The Makefile and docker-compose.yml files parameterize building the all images. You can build all the Docker images with: 

```
make build
```

You can build custom individual images by passing the required arguments: 

````
docker build -t docker-git-php-composer:custom \
--build-arg PHP_UNIT_VERSION=7.5.8  \
--build-arg PHP_VERSION=7.3  \
--build-arg UBUNTU_VERSION=18.04 ./bionic

````

Buildx Works too if you want to use that:

```
docker buildx build -t docker-git-php-composer:custom \
--build-arg PHP_UNIT_VERSION=7.5.8  \
--build-arg PHP_VERSION=7.4  \
--build-arg UBUNTU_VERSION=18.04 ./bionic
```


## Other than git, php and composer it contains:

- [phpunit](https://github.com/sebastianbergmann/phpunit/)
- Laravel Dusk support
- node
- yarn
- PHP_CodeSniffer
- phpmd
- xdebug disabled
- deployer


A different Dockerfile is included for Bionic and Xenial because of chromium support in Focal has changed. You can no longer install the "chromium-browser" package using apt-get, so we use an alternative approach and install chromium binaries via composer. 


You can find the list of tags below. 

- latest
- 'focal-php7.3-phpunit7.5.8'
- 'focal-php7.3-phpunit8.5.5'
- 'focal-php7.4-phpunit7.5.8'
- 'focal-php7.4-phpunit8.5.5'
- 'focal-php7.4-phpunit9.2.1'
- 'bionic-php7.3-phpunit7.5.8'
- 'bionic-php7.4-phpunit8.5.5'
- 'bionic-php7.4-phpunit9.2.1'
- 'xenial-php7.3-phpunit7.5.8'
- 'xenial-php7.4-phpunit8.5.5'
- 'xenial-php7.4-phpunit9.2.1'

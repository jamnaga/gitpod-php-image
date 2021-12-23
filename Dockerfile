FROM buildpack-deps:disco

### base ###
RUN yes | unminimize \
    && apt-get install -yq \
        asciidoctor \
        bash-completion \
        build-essential \
        htop \
        jq \
        less \
        locales \
        man-db \
        nano \
        software-properties-common \
        sudo \
        vim \
        unzip \
        multitail \
    && locale-gen en_US.UTF-8 \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*
ENV LANG=en_US.UTF-8

### Gitpod user ###
# '-l': see https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#user
RUN useradd -l -u 33333 -G sudo -md /home/gitpod -s /bin/bash -p gitpod gitpod \
    # passwordless sudo for users in the 'sudo' group
    && sed -i.bkp -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers
ENV HOME=/home/gitpod
WORKDIR $HOME
# custom Bash prompt
RUN { echo && echo "PS1='\[\e]0;\u \w\a\]\[\033[01;32m\]\u\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\] \\\$ '" ; } >> .bashrc

### Apache and Nginx ###

RUN apt-get update && apt-get install -yq \
        apache2 \
    && apt-get clean && rm -rf /tmp/* \
    && mkdir /var/run/apache2 \
    && mkdir /var/lock/apache2 \
    && ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load \
    && chown -R gitpod:gitpod /etc/apache2 /var/run/apache2 /var/lock/apache2 /var/log/apache2
COPY apache2/ /etc/apache2/

## The directory relative to your git repository that will be served by Apache / Nginx
ENV APACHE_DOCROOT_IN_REPO="public"

### PHP ###
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -yq \
        composer \
        php \
        php-all-dev \
        php-ctype \
        php-curl \
        php-date \
        php-gd \
        php-gettext \
        php-intl \
        php-json \
        php-mbstring \
        php-mysql \
        php-net-ftp \
        php-pgsql \
        php-sqlite3 \
        php-tokenizer \
        php-xml \
        php-zip \
    && apt-get clean && /tmp/*
# PHP language server is installed by theia-php-extension

### Gitpod user (2) ###
USER gitpod
# use sudo so that user does not get sudo usage info on (the first) login
RUN sudo echo "Running 'sudo' for Gitpod: success"

#RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# And clean up the image

RUN rm -rf /var/lib/apt/lists

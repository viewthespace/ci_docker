FROM ubuntu:14.04

RUN apt-get update -qq && apt-get install -y build-essential software-properties-common \
      git libxml2-dev libxslt1-dev sqlite3 libsqlite3-dev libssl-dev libreadline-dev libyaml-dev \
      zlib1g-dev libffi-dev libcurl4-openssl-dev curl unzip zip

#install ruby
RUN apt-add-repository -y ppa:brightbox/ruby-ng && \
  apt-get update && \
  apt-get install -y ruby2.3 ruby2.3-dev

ENV BUNDLER_VERSION 1.13.7
RUN gem install bundler --version "$BUNDLER_VERSION"
# install things globally, for great justice
# and don't create ".bundle" in all our apps
ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_PATH="$GEM_HOME" \
  BUNDLE_BIN="$GEM_HOME/bin" \
  BUNDLE_SILENCE_ROOT_WARNING=1 \
  BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH $BUNDLE_BIN:$PATH
RUN mkdir -p "$GEM_HOME" "$BUNDLE_BIN" \
  && chmod 777 "$GEM_HOME" "$BUNDLE_BIN"

# Install PostgreSQL
# -- Add the PostgreSQL PGP key to verify their Debian packages.
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8

# -- Add PostgreSQL's repository. It contains the most recent stable release
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# -- Install PostgreSQL 9.4
RUN apt-get update -y -qq && apt-get install -y \
  postgresql-client-9.4 \
  postgresql-contrib-9.4 \
  libpq-dev

#Install python so we can install aws-cli for caching
RUN apt-get install -y python python-dev python-pip python-virtualenv && \
  rm -rf /var/lib/apt/lists/*

#Install aws cli
RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" && \
unzip awscli-bundle.zip && \
./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws && \
rm -rf awscli-bundle

# PhantomJS

## for a JS runtime
#nodejs
RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
RUN apt-get install -y nodejs

# Env
ENV PHANTOMJS_VERSION 2.1.1

# Commands
RUN \
  apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y vim git wget libfreetype6 libfontconfig bzip2 && \
  mkdir -p /srv/var && \
  wget -q --no-check-certificate -O /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 && \
  tar -xjf /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 -C /tmp && \
  rm -f /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 && \
  mv /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64/ /srv/var/phantomjs && \
  ln -s /srv/var/phantomjs/bin/phantomjs /usr/bin/phantomjs && \
  git clone https://github.com/n1k0/casperjs.git /srv/var/casperjs && \
  ln -s /srv/var/casperjs/bin/casperjs /usr/bin/casperjs && \
  apt-get autoremove -y && \
  apt-get clean all


ENV BUNDLE_JOBS=4 \
  LANG="C.UTF-8" \
  LC_ALL="C.UTF-8"


ENV FIREFOX_VERSION 37.0.2
RUN apt-get update -qqy \
  && apt-get -y install xvfb \
  && apt-get -qqy --no-install-recommends install firefox \
  && rm -rf /var/lib/apt/lists/* \
  && wget --no-verbose -O /tmp/firefox.tar.bz2 https://download-installer.cdn.mozilla.net/pub/firefox/releases/$FIREFOX_VERSION/linux-x86_64/en-US/firefox-$FIREFOX_VERSION.tar.bz2 \
  && apt-get -y purge firefox \
  && rm -rf /opt/firefox \
  && tar -C /opt -xjf /tmp/firefox.tar.bz2 \
  && rm /tmp/firefox.tar.bz2 \
  && mv /opt/firefox /opt/firefox-$FIREFOX_VERSION \
  && ln -fs /opt/firefox-$FIREFOX_VERSION/firefox /usr/bin/firefox

RUN add-apt-repository -y "deb http://archive.canonical.com/ubuntu $(lsb_release -sc) partner" && \
    apt-get -y update && \
    apt-get install -y adobe-flashplugin && \
    apt-get install -y libvpx1 && \
    apt-get install -y libasound2 && \
    apt-get autoremove -y && \
    apt-get clean all




FROM ubuntu:14.04


RUN apt-get update -qq && apt-get install -y build-essential software-properties-common \
  git libxml2-dev libxslt1-dev sqlite3 libsqlite3-dev libssl-dev libreadline-dev libyaml-dev \
  zlib1g-dev libffi-dev libcurl4-openssl-dev curl unzip

#install ruby
RUN apt-add-repository -y ppa:brightbox/ruby-ng && \
    apt-get update && \
    apt-get install -y ruby2.3 ruby2.3-dev

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

# Install QT
RUN add-apt-repository ppa:beineri/opt-qt551-trusty && \
    apt-get update && \
    apt-get install -y qt55-meta-full mesa-common-dev libglu1-mesa-dev


# -- Update env for QT
ENV QT_BASE_DIR=/opt/qt55
ENV QTDIR=$QT_BASE_DIR
ENV PATH=$QT_BASE_DIR/bin:$PATH
ENV LD_LIBRARY_PATH=$QT_BASE_DIR/lib/x86_64-linux-gnu:$QT_BASE_DIR/lib:$LD_LIBRARY_PATH
ENV PKG_CONFIG_PATH=$QT_BASE_DIR/lib/pkgconfig:$PKG_CONFIG_PATH

#Xvfb for capybara-webkit
RUN apt-get install -y xvfb
ENV DISPLAY=:99

## for a JS runtime
#nodejs
RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
RUN apt-get install -y nodejs


ENV BUNDLE_JOBS=4 \
  LANG="C.UTF-8" \
  LC_ALL="C.UTF-8" \
  BUNDLE_PATH=/bundle

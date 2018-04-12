FROM ubuntu:latest

# Elixir requires UTF-8
RUN apt-get update && apt-get upgrade -y && apt-get install locales && locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# update and install software
RUN apt-get install -y curl wget git make sudo \
  # download and install Erlang apt repo package
  && wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb \
  && dpkg -i erlang-solutions_1.0_all.deb \
  && apt-get update \
  && rm erlang-solutions_1.0_all.deb \
  # For some reason, installing Elixir tries to remove this file
  # and if it doesn't exist, Elixir won't install. So, we create it.
  # Thanks Daniel Berkompas for this tip.
  # http://blog.danielberkompas.com
  && touch /etc/init.d/couchdb \
  # install latest elixir package
  && apt-get install -y elixir erlang-dev erlang-dialyzer erlang-parsetools \
  # clean up after ourselves
  && apt-get clean

# install the Phoenix Mix archive
RUN mix local.hex --force \
  && mix local.rebar --force

# install Node.js (>= 8.0.0) and NPM in order to satisfy brunch.io dependencies
# See https://hexdocs.pm/phoenix/installation.html#node-js-5-0-0
RUN curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash - && sudo apt-get install -y inotify-tools nodejs

# make default dir in container
WORKDIR /root/app

# copy application sources to docker image
ADD ./ /root/app/

# install and build npm assets
RUN cd assets && npm install && node node_modules/brunch/bin/brunch build --production

RUN mix deps.get
RUN mix compile

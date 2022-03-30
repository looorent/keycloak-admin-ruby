FROM ruby:2.7.5-slim-bullseye

RUN apt-get update -qq && apt-get install -y build-essential git ruby-dev && apt-get clean && \
  mkdir -p /usr/src/app/lib/keycloak-admin
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
COPY keycloak-admin.gemspec /usr/src/app/
COPY lib/keycloak-admin/version.rb /usr/src/app/lib/keycloak-admin/
# RUN bundle install
COPY . /usr/src/app
# RUN bundle install
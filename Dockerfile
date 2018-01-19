FROM ruby:2.3
RUN mkdir -p /usr/src/app/lib/keycloak-admin
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
COPY keycloak-admin.gemspec /usr/src/app/
COPY lib/keycloak-admin/version.rb /usr/src/app/lib/keycloak-admin/
RUN bundle install
COPY . /usr/src/app
RUN bundle install
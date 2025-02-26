FROM docker.io/ruby:3.4.2-alpine3.21

# Packages db must be updated first, add os dependencies
# required by Ruby gems (in this case just passenger)
RUN apk update && apk upgrade --available && apk add build-base ruby-dev linux-headers make bash sqlite

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir /usr/src/app
WORKDIR /usr/src/app
COPY . .

RUN bundle install

EXPOSE 3000

ENTRYPOINT ["bash", "scripts/entrypoint.sh"]

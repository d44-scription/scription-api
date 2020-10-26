FROM ruby:2.7

ADD . /usr/src/app
WORKDIR /usr/src/app

# Install & run bundler
RUN gem install bundler:'~> 2.1.4'

RUN bundle

CMD ./docker-entrypoint.sh

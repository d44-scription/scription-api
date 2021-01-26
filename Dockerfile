FROM ruby:3.0.0

ADD . /usr/src/app
WORKDIR /usr/src/app

# Install & run bundler
RUN gem install bundler:'~> 2.1.4'

RUN bundle

CMD ./docker-entrypoint.sh

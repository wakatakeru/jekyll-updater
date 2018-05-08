FROM ruby:2.5.0

ADD . /app
WORKDIR /app
RUN bundle install -j4
FROM ruby:2.5.0
RUN apt-get update -yqq \
    && apt-get install -yqq nodejs \
    && apt-get -q clean \
    && rm -rf /var/lib/apt/lists
WORKDIR /usr/src/app
COPY Gemfile* ./
RUN bundle install
COPY . .
EXPOSE 3000
RUN  ln -s /usr/src/app/tmp /tmp
CMD rm -f tmp/pids/server.pid && rails server -b 0.0.0.0 -p 3000

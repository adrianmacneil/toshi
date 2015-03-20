FROM ruby:2.1.5

RUN apt-get update \
  && apt-get install -y libpq-dev postgresql-client-9.4 \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /app
WORKDIR /app

COPY ./Gemfile* /app/
RUN bundle install

COPY . /app

EXPOSE 5000

ENTRYPOINT ["bundle", "exec"]
CMD ["puma"]

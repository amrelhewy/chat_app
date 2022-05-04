FROM ruby:2.7.1
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client git
ENV APP_PATH /chat_app

WORKDIR ${APP_PATH}
COPY Gemfile ${APP_PATH}/Gemfile
COPY Gemfile.lock ${APP_PATH}/Gemfile.lock


COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh


EXPOSE 3000

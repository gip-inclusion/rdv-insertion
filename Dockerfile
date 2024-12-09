FROM ruby:3.3.3-slim

EXPOSE 3000

RUN apt-get update && apt-get upgrade -y && apt-get install --no-install-recommends -y build-essential libpq-dev nodejs npm git curl

# do the bundle install in another directory with the strict essential
# (Gemfile and Gemfile.lock) to allow further steps to be cached
# (namely the NPM steps)
WORKDIR /bundle
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Move to the main folder
WORKDIR /app

# We can't do the WORKDIR trick here because npm modules need to be
# installed in the root folder (since they're installed locally in
# node_modules)
COPY package.json yarn.lock ./

RUN npm install -g yarn && yarn install

COPY . .

ENTRYPOINT ["./entrypoint.sh"]

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]

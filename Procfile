web: jemalloc.sh bundle exec puma -C config/puma.rb
postdeploy: bundle exec rake db:migrate
worker: bundle exec sidekiq

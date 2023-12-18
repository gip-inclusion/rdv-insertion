Statisfy.configure do |config|
  config.redis_client = Redis.new
  config.append_to_counters = ->(_) { include Sidekiq::Worker }
  config.default_scopes = -> { [subject.organisation, subject.department] }
end

Rails.application.config.after_initialize do
  Dir[Rails.root.join("app/stats/counters/**/*.rb")].each { |file| require file }
end

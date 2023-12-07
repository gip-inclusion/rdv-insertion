Statisfy.configure do |config|
  config.redis_client = Redis.new
  config.append_to_counters = ->(_) { include Sidekiq::Worker }
end

Rails.application.config.after_initialize do
  Dir[Rails.root.join("app/events/stats/counters/**/*.rb")].each { |file| require file }
end

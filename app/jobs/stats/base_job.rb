module Stats
  class BaseJob < ApplicationJob
    queue_as :stats
    sidekiq_options retry: 3
  end
end

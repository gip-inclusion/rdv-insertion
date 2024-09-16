module Stats
  class BaseJob < ApplicationJob
    queue_as :stats
  end
end

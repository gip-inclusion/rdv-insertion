class ApplicationJob
  include Sidekiq::Worker
  include EnvironmentsHelper
end

class ApplicationJob
  include Sidekiq::Worker
  include EnvironmentsHelper
  include JobSessionConcern
end

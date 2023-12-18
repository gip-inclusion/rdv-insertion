class ApplicationJob
  include Sidekiq::Worker
  include EnvironmentsHelper

  def set_current_agent(email) # rubocop:disable Naming/AccessorMethodName
    Current.agent ||= Agent.find_by(email:)
  end
end

module JobSessionConcern
  extend ActiveSupport::Concern

  def set_current_agent(email) # rubocop:disable Naming/AccessorMethodName
    Current.agent ||= Agent.find_by(email:)
  end
end

module JobSessionConcern
  extend ActiveSupport::Concern

  def rdv_solidarites_session(credentials)
    @rdv_solidarites_session ||= RdvSolidaritesSessionFactory.create_with(**credentials)
  end

  def current_agent(credentials)
    @current_agent ||= Agent.find_by(email: credentials[:uid])
  end
end

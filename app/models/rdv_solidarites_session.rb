class RdvSolidaritesSession
  attr_reader :uid

  private_class_method :new

  def self.from(provider)
    case provider
    when :login
      LoginSession
    when :inclusion_connect
      InclusionConnectSession
    else
      raise "session provider #{provider} unknown"
    end
  end

  def self.with(...) = new(...)

  def rdv_solidarites_client
    @rdv_solidarites_client ||= RdvSolidaritesClient.new(rdv_solidarites_session: self)
  end
end

class RdvSolidaritesSession
  attr_reader :provider

  delegate :valid?, :to_h, :uid, to: :provider

  def initialize(provider:)
    @provider = provider
  end

  def self.from(provider)
    new(provider: provider)
  end

  def rdv_solidarites_client
    @rdv_solidarites_client ||= RdvSolidaritesClient.new(rdv_solidarites_session: self)
  end
end

module RdvSolidaritesCredentials
  class Base
    attr_reader :uid

    def valid?
      raise NoMethodError
    end

    def to_h
      raise NoMethodError
    end

    def rdv_solidarites_client
      @rdv_solidarites_client ||= RdvSolidaritesClient.new(rdv_solidarites_credentials: to_h)
    end
  end
end

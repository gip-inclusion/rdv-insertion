module RdvSolidaritesSession
  class Base
    attr_reader :uid

    def valid?
      raise NoMethodError
    end

    def credentials
      raise NoMethodError
    end

    def rdv_solidarites_client
      @rdv_solidarites_client ||= RdvSolidaritesClient.new(rdv_solidarites_credentials: credentials)
    end
  end
end

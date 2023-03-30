module RdvSolidaritesSession
  class Base
    attr_reader :uid

    def valid?
      raise NotImplementedError
    end

    def to_h
      raise NotImplementedError
    end

    def rdv_solidarites_client
      @rdv_solidarites_client ||= RdvSolidaritesClient.new(rdv_solidarites_session: self)
    end
  end
end

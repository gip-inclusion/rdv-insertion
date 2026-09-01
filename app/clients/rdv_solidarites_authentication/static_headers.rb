module RdvSolidaritesAuthentication
  class StaticHeaders
    def initialize(headers:)
      @headers = headers
    end

    attr_reader :headers

    def renewable?
      false
    end
  end
end

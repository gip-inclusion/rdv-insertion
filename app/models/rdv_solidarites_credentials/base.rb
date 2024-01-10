module RdvSolidaritesCredentials
  class Base
    attr_reader :uid

    def valid?
      raise NoMethodError
    end

    def to_h
      raise NoMethodError
    end
  end
end

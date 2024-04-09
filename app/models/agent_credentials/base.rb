module AgentCredentials
  class Base
    attr_reader :uid

    def initialize(uid:)
      @uid = uid
    end

    def valid?
      raise NoMethodError
    end

    def to_h
      raise NoMethodError
    end
  end
end

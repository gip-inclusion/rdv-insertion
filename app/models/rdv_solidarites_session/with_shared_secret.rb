module RdvSolidaritesSession
  class WithSharedSecret < Base
    def initialize(uid:, x_agent_auth_signature:)
      @uid = uid
      @x_agent_auth_signature = x_agent_auth_signature
    end

    def valid?
      required_attributes_present? && signature_valid?
    end

    def to_h
      {
        "uid" => @uid,
        "x_agent_auth_signature" => @x_agent_auth_signature
      }
    end

    private

    def required_attributes_present?
      [@uid, @x_agent_auth_signature].all?(&:present?)
    end

    def signature_valid?
      ActiveSupport::SecurityUtils.secure_compare(
        Current.agent.signature_auth_with_shared_secret, @x_agent_auth_signature
      )
    end
  end
end

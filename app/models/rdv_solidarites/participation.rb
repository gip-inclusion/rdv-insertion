module RdvSolidarites
  class Participation < Base
    RECORD_ATTRIBUTES = [
      :id, :status, :created_by_type, :created_by, :created_by_agent_prescripteur, :created_by_id
    ].freeze
    attr_reader(*RECORD_ATTRIBUTES)

    delegate :collectif?, :motif, to: :rdv

    def rdv
      RdvSolidarites::Rdv.new(@attributes[:rdv])
    end

    def user
      RdvSolidarites::User.new(@attributes[:user])
    end

    def convocable?
      motif.convocation? || (collectif? && created_by == "agent")
    end
  end
end

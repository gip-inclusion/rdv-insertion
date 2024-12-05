module RdvSolidarites
  class ReferentAssignation < Base
    RECORD_ATTRIBUTES = [:id, :agent, :user].freeze

    def agent
      RdvSolidarites::Agent.new(@attributes[:agent])
    end
  end
end

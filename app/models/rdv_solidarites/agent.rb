module RdvSolidarites
  class Agent < Base
    RECORD_ATTRIBUTES = [:id, :email, :first_name, :last_name].freeze
    attr_reader(*RECORD_ATTRIBUTES)
  end
end

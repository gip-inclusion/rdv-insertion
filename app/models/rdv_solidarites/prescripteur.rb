module RdvSolidarites
  class Prescripteur < Base
    RECORD_ATTRIBUTES = [:id, :first_name, :last_name, :email].freeze
    attr_reader(*RECORD_ATTRIBUTES)
  end
end

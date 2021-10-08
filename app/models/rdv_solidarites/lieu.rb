module RdvSolidarites
  class Lieu < Base
    RECORD_ATTRIBUTES = [:id, :address, :name].freeze
    attr_reader(*RECORD_ATTRIBUTES)
  end
end

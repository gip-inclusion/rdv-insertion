module RdvSolidarites
  class Organisation < Base
    RECORD_ATTRIBUTES = [:id, :name].freeze
    attr_reader(*RECORD_ATTRIBUTES)
  end
end

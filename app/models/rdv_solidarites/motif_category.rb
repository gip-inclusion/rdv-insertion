module RdvSolidarites
  class MotifCategory < Base
    RECORD_ATTRIBUTES = [
      :id, :name, :short_name
    ].freeze
    attr_reader(*RECORD_ATTRIBUTES)
  end
end

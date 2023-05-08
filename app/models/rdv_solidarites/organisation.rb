module RdvSolidarites
  class Organisation < Base
    RECORD_ATTRIBUTES = [:id, :name, :phone_number, :email, :verticale].freeze
    attr_reader(*RECORD_ATTRIBUTES)
  end
end

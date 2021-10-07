module RdvSolidarites
  class User < Base
    RECORD_ATTRIBUTES = [
      :id, :first_name, :last_name, :birth_date, :email, :phone_number, :phone_number_formatted,
      :birth_name, :address, :affiliation_number, :created_at, :invited_at, :invitation_accepted_at
    ].freeze
    attr_reader(*RECORD_ATTRIBUTES)
  end
end

module RdvSolidarites
  class Participation < Base
    RECORD_ATTRIBUTES = [
      :id, :status, :created_by
    ].freeze
    attr_reader(*RECORD_ATTRIBUTES)

    def user
      RdvSolidarites::User.new(@attributes[:user])
    end
  end
end

module RdvSolidarites
  class Participation < Base
    RECORD_ATTRIBUTES = [
      :id, :status
    ].freeze
    attr_reader(*RECORD_ATTRIBUTES)

    def user
      RdvSolidarites::User.new(@attributes[:user])
    end
  end
end

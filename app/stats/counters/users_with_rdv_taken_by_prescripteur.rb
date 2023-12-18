module Counters
  class UsersWithRdvTakenByPrescripteur
    include Statisfy::Counter

    count every: :participation_created,
          if: -> { participation.created_by == "prescripteur" },
          uniq_by: -> { participation.user_id }
  end
end

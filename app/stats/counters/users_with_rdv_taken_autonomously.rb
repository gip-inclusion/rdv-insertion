module Counters
  class UsersWithRdvTakenAutonomously
    include Statisfy::Counter

    count every: :participation_created,
          if: -> { participation.created_by == "user" },
          uniq_by: -> { participation.user_id }
  end
end

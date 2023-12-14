module Counters
  class UsersWithRdvTakenByAgent
    include Statisfy::Counter

    count every: :participation_created,
          if: -> { participation.created_by == "agent" },
          uniq_by: -> { participation.user_id }
  end
end

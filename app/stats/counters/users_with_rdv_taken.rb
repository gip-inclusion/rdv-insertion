module Counters
  class UsersWithRdvTaken
    include Statisfy::Counter

    count every: :participation_created,
          uniq_by: -> { participation.user_id }
  end
end

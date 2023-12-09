module Counters
  class UsersWithRdvTaken
    include Statisfy::Counter

    count every: :participation_created,
          uniq_by: -> { participation.user_id },
          on_destroy: -> { decrement if Participation.where(user_id: participation.user_id).empty? }
  end
end

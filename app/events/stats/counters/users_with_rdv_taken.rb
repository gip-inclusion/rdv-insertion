module Stats
  module Counters
    class UsersWithRdvTaken
      include Counter

      count every: :create_participation,
            uniq_by: -> { participation.user_id }
    end
  end
end

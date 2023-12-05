module Stats
  module Counters
    class UsersCreated
      include Counter

      count every: :create_user,
            scopes: -> { [user.departments, user.organisations] }
    end
  end
end

module Stats
  module Counters
    class UsersCreated
      include Counter

      count every: :create_user,
            scopes: -> { [user.departments.to_a, user.organisations.to_a] }
    end
  end
end

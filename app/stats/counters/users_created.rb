module Counters
    class UsersCreated
      include Statisfy::Counter

      count every: :user_created,
            scopes: -> { [user.departments, user.organisations] }
  end
end

module Stats
  module CounterCache
    class UsersCreated
      include Counter

      catch_events :create_user_successful

      def scopes
        [user.departments.to_a, user.organisations.to_a].flatten.compact
      end
    end
  end
end

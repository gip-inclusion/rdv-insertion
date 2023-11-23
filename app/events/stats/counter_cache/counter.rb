module Stats
  module CounterCache
    module Counter
      extend ActiveSupport::Concern

      class_methods do
        #
        # This is the method that is called when you want to get the value of a counter.
        #
        # By default it returns the number of elements in the set.
        # You can override it if the counter requires more complex logic
        # see RateOfAutonomousUsers for example
        #
        # @param scope: the scope of the counter (an Organisation or a Department)
        # @param month: the month for which you want the value of the counter (optional)
        #
        def value(scope:, month: nil)
          number_of_elements_in(scope:, month:)
        end

        def number_of_elements_in(scope:, month: nil, group: nil)
          redis_client.scard(key_for(group:, scope:, month:))
        end

        #
        # Returns the list of elements in the set (in case you use .append and not .increment)
        #
        def elements_in(scope:, month: nil, group: nil)
          redis_client.lrange(key_for(group:, scope:, month:), 0, -1)
        end

        #
        # Returns the average of the elements in the set
        # Example:
        # append(value: 1)
        # append(value: 2)
        # average_for(scope: Organisation.first) # => 1.5
        #
        def average_for(scope:, month: nil)
          stored_values = elements_in(scope:, month:)
          return 0 if stored_values.empty?

          stored_values.map(&:to_i).reduce(:+) / stored_values.length.to_f
        end

        #
        # This is the name of the Redis key that will be used to store the counter
        #
        def key_for(scope:, month: nil, group: nil)
          {
            counter: name.demodulize.underscore,
            group:,
            month:,
            scope_type: scope.class.name,
            scope_id: scope.id
          }.to_json
        end

        def redis_client
          @redis_client ||= Redis.new
        end

        #
        # Returns a hash of values grouped by month:
        # {
        #   "01/2024" => 33.3,
        #   "02/2024" => 36.6,
        #   "03/2024" => 38.2,
        # }
        #
        def values_grouped_by_month(scope:)
          twelve_last_months = (0..11).map { |i| (11 - i).months.ago.beginning_of_month }
          twelve_last_months.to_h do |month|
            [month.strftime("%m/%Y"), value(scope: scope, month: month.strftime("%Y-%m")).round(2)]
          end
        end

        #
        # This allows to run a counter increment manually
        # It is useful when you want to backfill counters
        #
        def initialize_with(subject, options = {})
          counter = new
          return unless options[:skip_validation] || (counter.respond_to?(:run_if) ? counter.run_if(subject) : true)

          counter.perform(subject)
        end
      end

      protected

      def scopes_with_global
        scopes + [Department.new]
      end

      def month_to_set
        params["created_at"].to_date.strftime("%Y-%m")
      end

      def identifier
        params["id"]
      end

      def scopes
        [subject.department, subject.organisation]
      end

      #
      # This allows to iterate over all the counters that need to be updated
      # (in general the Department(s) and Organisation(s) for both the current month and the global counter)
      #
      def all_counters_of(group:)
        [month_to_set, nil].each do |month|
          scopes_with_global.each do |scope|
            yield self.class.key_for(group:, scope:, month:), identifier
          end
        end
      end

      def increment(group: nil)
        all_counters_of(group:) do |key, id|
          self.class.redis_client.sadd?(key, id)
        end
      end

      def decrement(group: nil)
        all_counters_of(group:) do |key, id|
          self.class.redis_client.srem?(key, id)
        end
      end

      #
      # To be used to store a list of values instead of a basic counter
      #
      def append(value:, group: nil)
        all_counters_of(group:) do |key|
          self.class.redis_client.rpush(key, value)
        end
      end

      #
      # Default behaviour is to increment the counter
      # You can override this method if you want to do something else
      #
      def process_event
        increment
      end
    end
  end
end

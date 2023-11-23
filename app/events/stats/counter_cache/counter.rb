module Stats
  module CounterCache
    module Counter
      extend ActiveSupport::Concern

      class_methods do
        def value(scope:, month: nil)
          counter_for(scope:, month:)
        end

        def counter_for(scope:, month: nil, group: nil)
          redis_client.scard(key_for(group:, scope:, month:))
        end

        def list_for(scope:, month: nil, group: nil)
          redis_client.lrange(key_for(group:, scope:, month:), 0, -1)
        end

        def average_for(scope:, month: nil)
          stored_values = list_for(scope:, month:)
          return 0 if stored_values.empty?

          stored_values.map(&:to_i).reduce(:+) / stored_values.length.to_f
        end

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

      def append(value:, group: nil)
        all_counters_of(group:) do |key|
          self.class.redis_client.rpush(key, value)
        end
      end

      def process_event
        increment
      end
    end
  end
end

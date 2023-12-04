# rubocop:disable Metrics/ModuleLength

module Stats
  module Counters
    module Counter
      extend ActiveSupport::Concern

      class_methods do
        #
        # This is a DSL method that helps you define a counter
        # It will create a method that will be called when the event is triggered
        # It will also create a method that will be called when you want to get the value of the counter
        #
        # @param every: the event(s) that will trigger the counter
        # @param type: by default it increments, but you can also use :average
        # @param where: a block that returns a condition that must be met for the counter to be incremented (optional)
        # @param uniq_by: a block to get the identifier of the element to be counted (optional)
        # @param scopes: a block to get the list of scopes for which the counter must be incremented (optional)
        #
        # rubocop:disable Metrics/AbcSize
        def count(args = {})
          raise ArgumentError, "You must provide at least one event" if args[:every].blank?

          catch_events(
            *[*args[:every]].flatten.map { |event| "#{event}_successful".to_sym },
            if: args[:where] || -> { true }
          )

          define_method(:identifier, args[:uniq_by]) if args[:uniq_by].present?
          define_method(:scopes, args[:scopes]) if args[:scopes].present?
          define_process_event_method(args)
          const_set(:COUNTER_TYPE, args[:type] || :increment)
        end
        # rubocop:enable Metrics/AbcSize

        def define_process_event_method(args)
          define_method(:where_async, args[:where_async] || -> { true })
          define_method(:decrement?, args[:decrement_if] || -> { false })
          define_method(:value, args[:value] || -> {})
          define_method(:process_event) do
            next unless where_async

            if args[:value]
              append(value:)
            else
              decrement? ? decrement : increment
            end
          end
        end

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
          if const_get(:COUNTER_TYPE) == :average
            average_for(scope:, month:)
          else
            number_of_elements_in(scope:, month:)
          end
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
        # @param scope: the scope of the counter (an Organisation or a Department)
        # @param start_at: the date from which you want to start counting (optional)
        # @param stop_at: the date at which you want to stop counting (optional)
        #
        # rubocop:disable Metrics/AbcSize
        def values_grouped_by_month(scope:, start_at: nil, stop_at: nil)
          x_months = 24

          if start_at.present? || scope&.created_at.present?
            start_at ||= scope.created_at
            x_months = ((Time.zone.today.year * 12) + Time.zone.today.month) - ((start_at.year * 12) + start_at.month)
          end

          relevant_months = (0..x_months).map do |i|
            (x_months - i).months.ago.beginning_of_month
          end

          relevant_months
            .filter { |month| stop_at.blank? || month < stop_at }
            .to_h do |month|
            [month.strftime("%m/%Y"), value(scope: scope, month: month.strftime("%Y-%m")).round(2)]
          end
        end
        # rubocop:enable Metrics/AbcSize

        #
        # This allows to run a counter increment manually
        # It is useful when you want to backfill counters
        #
        def initialize_with(subject, options = {})
          counter = new
          return unless options[:skip_validation] || (counter.respond_to?(:run_if) ? counter.run_if(subject) : true)

          counter.perform(subject)
        end

        #
        # Returns the list of all the keys of this counter for a given scope (optional)
        # and a given month (optional)
        #
        def all_keys(scope: nil, month: nil, group: nil) # rubocop:disable Metrics/AbcSize
          redis_client.keys("*\"counter\":\"#{name.demodulize.underscore}\"*").filter do |json|
            key = JSON.parse(json)

            scope_matches = scope.nil? || (key["scope_type"] == scope.class.name && key["scope_id"] == scope.id)
            month_matches = month.nil? || key["month"] == month
            group_matches = group.nil? || key["group"] == group

            scope_matches && month_matches && group_matches
          end
        end

        #
        # This allows to reset all the counters for a given scope (optional)
        # and a given month (optional)
        #
        def reset(scope: nil, month: nil, group: nil)
          all_keys(scope:, month:, group:).each do |key|
            redis_client.del(key)
          end

          true
        end
      end

      protected

      def scopes_with_global
        (scopes + [Department.new]).flatten.compact
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

      included do
        include EventSubscriber
      end
    end
  end
end

# rubocop:enable Metrics/ModuleLength

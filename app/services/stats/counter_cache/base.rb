module Stats
  module CounterCache
    class Base
      def initialize(subject)
        @subject = subject
      end

      def self.counter_for(key, scope:)
        redis_client.scard(key_for(key, scope))
      end

      def self.key_for(key, scope)
        {
          counter: self::COUNTER,
          key: key,
          scope_type: scope.class.name,
          scope_id: scope.id
        }.to_json
      end

      def self.redis_client
        @redis_client ||= Redis.new
      end

      protected

      def scopes_with_global
        scopes + [Department.new]
      end

      def increment(key: nil)
        scopes_with_global.each do |scope|
          self.class.redis_client.sadd(self.class.key_for(key, scope), @subject.id)
        end
      end

      def decrement(key: nil)
        scopes_with_global.each do |scope|
          self.class.redis_client.srem(self.class.key_for(key, scope), @subject.id)
        end
      end
    end
  end
end

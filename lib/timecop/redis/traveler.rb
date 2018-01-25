class Timecop
  module Redis
    class Traveler
      attr_reader :redis

      def initialize(redis)
        @redis = redis
      end

      # TODO: Support auto-rewind block
      def travel(from:, to:)
        advanced_milliseconds = ((to - from) * 1000).to_i

        expirable_keys.each do |key, old_remaining_milliseconds|
          new_remaining_milliseconds = old_remaining_milliseconds - advanced_milliseconds

          if new_remaining_milliseconds > 0
            redis.pexpire(key, new_remaining_milliseconds)
          else
            redis.del(key)
          end
        end
      end

      private

      def expirable_keys
        return to_enum(__method__) unless block_given?

        redis.keys('*').each do |key|
          # https://redis.io/commands/pttl
          # The command returns -2 if the key does not exist.
          # The command returns -1 if the key exists but has no associated expire.
          remaining_milliseconds = redis.pttl(key)
          next if remaining_milliseconds < 0
          yield key, remaining_milliseconds
        end
      end
    end
  end
end

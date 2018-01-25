require_relative 'redis/traveler'
require 'redis'
require 'timecop'

class Timecop
  module Redis
    class << self
      def redis
        @redis || ::Redis.current
      end

      def redis=(redis)
        @redis = redis
        @traveler = nil
      end

      def travel(new_time)
        traveler.travel(new_time)
      end

      private

      def traveler
        @traveler ||= Traveler.new(redis)
      end
    end
  end
end

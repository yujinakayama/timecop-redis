require_relative 'redis/timecop_integration'
require_relative 'redis/traveler'
require 'redis'

class Timecop
  module Redis
    class << self
      attr_accessor :integrate_into_timecop_travel
      alias integrate_into_timecop_travel? integrate_into_timecop_travel

      def redis
        @redis || ::Redis.new
      end

      def redis=(redis)
        @redis = redis
        @traveler = nil
      end

      def travel(new_time, &block)
        traveler.travel(from: Time.now, to: new_time, &block)
      end

      def traveler
        @traveler ||= Traveler.new(redis)
      end
    end

    self.integrate_into_timecop_travel = false
  end
end

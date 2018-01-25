require 'timecop'

# We directly patch Timecop class instead of mixin module
# since Singleton classes cannot be extended.
# https://github.com/ruby/ruby/blob/v2_5_0/lib/singleton.rb#L150-L151
class Timecop
  alias travel_without_redis travel

  def travel_with_redis(*args, &block)
    if Timecop::Redis.integrate_into_timecop_travel?
      old_time = Time.now
      travel_without_redis(*args, &block)
      new_time = Time.now
      Timecop::Redis.traveler.travel(from: old_time, to: new_time, &block)
    else
      travel_without_redis(*args, &block)
    end
  end

  alias travel travel_with_redis
end

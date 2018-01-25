require 'timecop/redis'

RSpec.describe Timecop::Redis do
  before do
    Timecop::Redis.redis = redis
  end

  let(:redis) do
    ::Redis.new
  end

  describe '.travel' do
    before do
      redis.setex('10_seconds_lifetime_key', 10, '10_seconds_lifetime_value')
      redis.setex('5_seconds_lifetime_key', 5, '5_seconds_lifetime_value')
      redis.set('persistent_key', 'persistent_value')
    end

    context 'when a future time is given' do
      it 'shortens lifetime of expirable keys or deletes expired keys as if the current time advanced to the given time' do
        expect { Timecop::Redis.travel(Time.now + 6) }
          .to not_change { Time.now.to_i }
         .and change { redis.pttl('10_seconds_lifetime_key') }.from(about(10_000).milliseconds).to(about(4_000).milliseconds)
         .and not_change { redis.get('10_seconds_lifetime_key') }.from('10_seconds_lifetime_value')
         .and change { redis.get('5_seconds_lifetime_key') }.from('5_seconds_lifetime_value').to(nil)
         .and not_change { redis.get('persistent_key') }.from('persistent_value')
      end
    end

    context 'when a past time is given' do
      it 'lengthens lifetime of expirable keys as if the current time rewinded to the given time' do
        expect { Timecop::Redis.travel(Time.now - 6) }
          .to not_change { Time.now.to_i }
         .and change { redis.pttl('10_seconds_lifetime_key') }.from(about(10_000).milliseconds).to(about(16_000).milliseconds)
         .and not_change { redis.get('10_seconds_lifetime_key') }.from('10_seconds_lifetime_value')
         .and change { redis.pttl('5_seconds_lifetime_key') }.from(about(5_000).milliseconds).to(about(11_000).milliseconds)
         .and not_change { redis.get('5_seconds_lifetime_key') }.from('5_seconds_lifetime_value')
         .and not_change { redis.get('persistent_key') }.from('persistent_value')
      end
    end
  end
end

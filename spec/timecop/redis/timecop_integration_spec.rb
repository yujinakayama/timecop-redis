require 'timecop/redis'

RSpec.describe 'Timecop integration' do
  around do |example|
    original_integrate_into_timecop_travel = Timecop::Redis.integrate_into_timecop_travel?
    example.run
    Timecop::Redis.integrate_into_timecop_travel = original_integrate_into_timecop_travel
  end

  before do
    Timecop::Redis.redis = redis
  end

  let(:redis) do
    ::Redis.new
  end

  describe 'Timecop.travel' do
    before do
      redis.setex('10_seconds_lifetime_key', 10, '10_seconds_lifetime_value')
      redis.setex('5_seconds_lifetime_key', 5, '5_seconds_lifetime_value')
      redis.set('persistent_key', 'persistent_value')
    end

    context 'when Timecop::Redis.integrate_into_timecop_travel? is true' do
      before do
        Timecop::Redis.integrate_into_timecop_travel = true
      end

      it 'changes lifetime of expirable keys or deletes expired keys as if the current time advanced to the given time' do
        expect { Timecop.travel(Time.now + 6) }
          .to change { Time.now.to_i }.to(Time.now.to_i + 6)
         .and change { redis.pttl('10_seconds_lifetime_key') }.from(about(10_000).milliseconds).to(about(4_000).milliseconds)
         .and not_change { redis.get('10_seconds_lifetime_key') }.from('10_seconds_lifetime_value')
         .and change { redis.get('5_seconds_lifetime_key') }.from('5_seconds_lifetime_value').to(nil)
         .and not_change { redis.get('persistent_key') }.from('persistent_value')
      end

      context 'when a block is given' do
        it 'raises ArgumentError' do
          expect { Timecop.travel(Time.now + 6) {} }.to raise_error(ArgumentError)
        end
      end
    end

    context 'when Timecop::Redis.integrate_into_timecop_travel? is false' do
      before do
        Timecop::Redis.integrate_into_timecop_travel = false
      end

      it 'does nothing about Redis' do
        expect { Timecop.travel(Time.now + 6) }
          .to change { Time.now.to_i }.to(Time.now.to_i + 6)
         .and not_change { redis.ttl('10_seconds_lifetime_key') }
         .and not_change { redis.get('10_seconds_lifetime_key') }
         .and not_change { redis.ttl('5_seconds_lifetime_key') }
         .and not_change { redis.get('5_seconds_lifetime_key') }
         .and not_change { redis.get('persistent_key') }
      end
    end
  end
end

module AboutMatcher
  def about(milliseconds)
    matcher = a_value_within(100).of(milliseconds)

    def matcher.method_missing(*) # rubocop:disable Style/MethodMissing
      self
    end

    matcher
  end
end

RSpec.configuration.include AboutMatcher

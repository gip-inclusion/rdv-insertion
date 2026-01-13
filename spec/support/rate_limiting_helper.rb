# frozen_string_literal: true

# Clear rate limit cache between tests to prevent rate limiting from affecting unrelated tests
RSpec.configure do |config|
  config.before do
    RateLimitingConcern::RATE_LIMIT_CACHE_STORE.clear if defined?(RateLimitingConcern)
  end
end

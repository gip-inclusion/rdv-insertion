RSpec.describe RateLimitingConcern do
  describe "#render_rate_limit_exceeded" do
    controller(ApplicationController) do
      include RateLimitingConcern # rubocop:disable RSpec/DescribedClass

      skip_before_action :authenticate_agent!

      def trigger_rate_limit
        render_rate_limit_exceeded(5, 1.minute)
      end
    end

    before do
      routes.draw { get "trigger_rate_limit" => "anonymous#trigger_rate_limit" }
      RateLimitingConcern::RATE_LIMIT_CACHE_STORE.clear
    end

    it "returns 429 Too Many Requests status" do
      get :trigger_rate_limit
      expect(response).to have_http_status(:too_many_requests)
    end

    it "returns structured JSON error body" do
      get :trigger_rate_limit

      body = response.parsed_body
      expect(body).to include(
        "error" => "Limite de requêtes atteinte",
        "retry_after" => 60,
        "message" => a_string_including("moins de 60 secondes")
      )
    end

    it "sets Retry-After header to the period" do
      get :trigger_rate_limit
      expect(response.headers["Retry-After"]).to eq("60")
    end

    it "sets X-RateLimit-Limit header to the configured limit" do
      get :trigger_rate_limit
      expect(response.headers["X-RateLimit-Limit"]).to eq("5")
    end

    it "sets X-RateLimit-Remaining header to 0" do
      get :trigger_rate_limit
      expect(response.headers["X-RateLimit-Remaining"]).to eq("0")
    end

    it "reports the rate limit exceeded to Sentry with a fingerprint per endpoint" do
      expect(Sentry).to receive(:capture_message).with(
        "Rate limit exceeded",
        fingerprint: %w[rate_limit_exceeded anonymous trigger_rate_limit],
        extra: hash_including(
          path: "/trigger_rate_limit",
          controller: "anonymous",
          action: "trigger_rate_limit"
        )
      )
      get :trigger_rate_limit
    end

    it "reports only the first exceeded request of an ip within the period" do
      expect(Sentry).to receive(:capture_message).once

      3.times { get :trigger_rate_limit }
    end

    it "remembers the report for the duration of the period only" do
      expect(RateLimitingConcern::RATE_LIMIT_CACHE_STORE).to receive(:write).with(
        "reported:anonymous:trigger_rate_limit:0.0.0.0", true, expires_in: 1.minute, unless_exist: true
      ).and_call_original

      get :trigger_rate_limit
    end

    it "reports each ip separately" do
      expect(Sentry).to receive(:capture_message).twice

      request.remote_addr = "10.0.0.1"
      get :trigger_rate_limit
      request.remote_addr = "10.0.0.2"
      get :trigger_rate_limit
    end

    it "does not report to Sentry when the controller opts out" do
      allow(controller).to receive(:report_rate_limits_to_sentry?).and_return(false)
      expect(Sentry).not_to receive(:capture_message)

      get :trigger_rate_limit

      expect(response).to have_http_status(:too_many_requests)
    end

    it "logs the throttled request with useful context" do
      allow(Rails.logger).to receive(:warn)

      get :trigger_rate_limit

      expect(Rails.logger).to have_received(:warn).with(
        a_string_matching(/\[RateLimit\].*ip=.*path=.*controller=.*#/)
      )
    end
  end

  describe "#report_rate_limits_to_sentry?" do
    it "is disabled on public unauthenticated controllers" do
      expect(ErrorsController.new.send(:report_rate_limits_to_sentry?)).to be(false)
      expect(Website::StaticPagesController.new.send(:report_rate_limits_to_sentry?)).to be(false)
    end
  end

  describe ".override_rate_limit" do
    it "raises ArgumentError when limit is nil" do
      expect do
        Class.new(ApplicationController) do
          override_rate_limit limit: nil, period: 1.minute
        end
      end.to raise_error(ArgumentError, /a limit must be provided/)
    end

    it "marks all actions as overridden when no only: is specified" do
      controller_class = Class.new(ApplicationController) do
        override_rate_limit limit: 3, period: 1.minute
      end

      expect(controller_class.overridden_rate_limit_actions).to contain_exactly(:_all)
    end

    it "marks only specified actions as overridden" do
      controller_class = Class.new(ApplicationController) do
        override_rate_limit limit: 3, period: 1.minute, only: [:create, :update]
      end

      expect(controller_class.overridden_rate_limit_actions).to contain_exactly(:create, :update)
    end

    it "does not affect the parent class" do
      Class.new(ApplicationController) do
        override_rate_limit limit: 3, period: 1.minute
      end

      expect(ApplicationController.overridden_rate_limit_actions).to be_empty
    end

    it "does not affect sibling subclasses" do
      Class.new(ApplicationController) do
        override_rate_limit limit: 3, period: 1.minute
      end

      sibling = Class.new(ApplicationController)
      expect(sibling.overridden_rate_limit_actions).to be_empty
    end
  end
end

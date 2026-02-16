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

    it "reports the rate limit exceeded to Sentry" do
      expect(Sentry).to receive(:capture_message).with(
        "Rate limit exceeded",
        extra: hash_including(
          path: "/trigger_rate_limit",
          controller: "anonymous",
          action: "trigger_rate_limit"
        )
      )
      get :trigger_rate_limit
    end

    it "logs the throttled request with useful context" do
      allow(Rails.logger).to receive(:warn)

      get :trigger_rate_limit

      expect(Rails.logger).to have_received(:warn).with(
        a_string_matching(/\[RateLimit\].*ip=.*path=.*controller=.*#/)
      )
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

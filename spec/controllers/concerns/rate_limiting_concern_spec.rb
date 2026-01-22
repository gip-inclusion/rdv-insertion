# frozen_string_literal: true

require "rails_helper"

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
        "message" => a_string_including("Vous avez atteint le nombre de requêtes autorisées")
      )
      expect(body["retry_after"]).to be_a(Integer).and be_between(1, 60)
    end

    it "sets Retry-After header with seconds until reset" do
      get :trigger_rate_limit

      retry_after = response.headers["Retry-After"].to_i
      expect(retry_after).to be_between(1, 60)
    end

    it "sets X-RateLimit-Limit header to the configured limit" do
      get :trigger_rate_limit
      expect(response.headers["X-RateLimit-Limit"]).to eq("5")
    end

    it "sets X-RateLimit-Remaining header to 0" do
      get :trigger_rate_limit
      expect(response.headers["X-RateLimit-Remaining"]).to eq("0")
    end

    it "sets X-RateLimit-Reset header with ISO8601 timestamp" do
      freeze_time do
        get :trigger_rate_limit

        reset_time = Time.zone.parse(response.headers["X-RateLimit-Reset"])
        expect(reset_time).to be > Time.current
        expect(reset_time).to be <= 1.minute.from_now
      end
    end

    it "logs the throttled request with useful context" do
      allow(Rails.logger).to receive(:warn)

      get :trigger_rate_limit

      expect(Rails.logger).to have_received(:warn).with(
        a_string_matching(/\[RateLimit\].*ip=.*path=.*controller=.*#/)
      )
    end
  end

  describe ".rate_limit_with_json_response" do
    it "raises ArgumentError when limit is nil" do
      expect do
        Class.new(ApplicationController) do
          rate_limit_with_json_response limit: nil, period: 1.minute
        end
      end.to raise_error(ArgumentError, /a limit must be provided/)
    end
  end
end

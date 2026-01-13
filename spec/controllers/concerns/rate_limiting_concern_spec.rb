# frozen_string_literal: true

require "rails_helper"

RSpec.describe RateLimitingConcern do
  describe ".rate_limit_with_json_response" do
    it "is available as a class method when included" do
      test_class = Class.new(ActionController::Base) { include RateLimitingConcern }
      expect(test_class).to respond_to(:rate_limit_with_json_response)
    end
  end

  describe "#render_rate_limit_exceeded" do
    controller(ActionController::Base) do
      include RateLimitingConcern

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
        "error" => "Rate limit exceeded",
        "message" => a_string_including("exceeded the allowed number of requests")
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
        a_string_matching(/\[RateLimit\].*ip=.*path=.*controller=.*action=/)
      )
    end

    it "reports to Sentry with request context" do
      allow(Sentry).to receive(:capture_message)

      get :trigger_rate_limit

      expect(Sentry).to have_received(:capture_message).with(
        "Rate limit exceeded",
        hash_including(
          level: :warning,
          extra: hash_including(:ip, :path, :controller, :action, :user_agent)
        )
      )
    end
  end

  describe "RATE_LIMIT_CACHE_STORE" do
    it "uses Redis-backed cache store" do
      store = RateLimitingConcern::RATE_LIMIT_CACHE_STORE
      expect(store).to be_a(ActiveSupport::Cache::RedisCacheStore)
    end

    it "uses rate_limit namespace to avoid collisions" do
      store = RateLimitingConcern::RATE_LIMIT_CACHE_STORE
      expect(store.options[:namespace]).to eq("rate_limit")
    end
  end

  describe "controller inclusion" do
    # Verify the concern is included in the right controllers
    it "is included in ApplicationController" do
      expect(ApplicationController.ancestors).to include(described_class)
    end

    it "is included in Api::V1::ApplicationController" do
      expect(Api::V1::ApplicationController.ancestors).to include(described_class)
    end
  end
end

# Document expected rate limits for each controller
# These serve as living documentation and will fail if limits are accidentally removed
RSpec.describe "Rate limit configuration" do
  # Helper to check if controller has rate_limit calls in its source
  def controller_source(klass)
    file = klass.instance_method(:action_methods).source_location&.first
    return "" unless file

    # Get the controller file, not the method file
    controller_file = file.sub(%r{/concerns/.*}, ".rb")
    controller_file = "#{Rails.root}/app/controllers/#{klass.name.underscore}.rb"
    File.read(controller_file) if File.exist?(controller_file)
  rescue StandardError
    ""
  end

  describe "Authentication rate limits" do
    it "SessionsController has rate limits for brute force protection" do
      source = controller_source(SessionsController)
      expect(source).to include("rate_limit_with_json_response")
      expect(source).to match(/limit:\s*5.*only:\s*:new/m).or match(/limit:\s*5.*only:\s*:create/m)
    end

    it "SuperAdminAuthenticationRequestsController has strict 3/min limit" do
      source = controller_source(SuperAdminAuthenticationRequestsController)
      expect(source).to include("rate_limit_with_json_response")
      expect(source).to include("limit: 3")
    end
  end

  describe "API rate limits" do
    it "Api::V1::ApplicationController has 100/min general API limit" do
      source = controller_source(Api::V1::ApplicationController)
      expect(source).to include("rate_limit_with_json_response")
      expect(source).to include("limit: 100")
    end

    it "Api::V1::UsersController has tiered limits for creation operations" do
      source = controller_source(Api::V1::UsersController)
      # User creation: 20/min
      expect(source).to match(/limit:\s*20.*:create/m)
      # Bulk operations: 5/min (stricter)
      expect(source).to match(/limit:\s*5.*:create_and_invite_many/m)
    end
  end

  describe "Webhook rate limits" do
    %w[
      RdvSolidaritesWebhooksController
      Brevo::MailWebhooksController
      Brevo::SmsWebhooksController
      InboundEmailsController
    ].each do |controller_name|
      it "#{controller_name} has high 1000/min limit for webhook volume" do
        klass = controller_name.constantize
        source = controller_source(klass)
        expect(source).to include("limit: 1000")
      end
    end
  end

  describe "Public endpoint rate limits" do
    it "InvitationsController has rate limits for public invitation pages" do
      source = controller_source(InvitationsController)
      expect(source).to include("rate_limit_with_json_response")
      expect(source).to match(/limit:\s*30/)
      expect(source).to match(/limit:\s*20/)
    end

    it "Website::StaticPagesController has rate limits" do
      source = controller_source(Website::StaticPagesController)
      expect(source).to include("limit: 60")
    end

    it "Website::StatsController has rate limits" do
      source = controller_source(Website::StatsController)
      expect(source).to include("limit: 60")
    end
  end

  describe "Search endpoint rate limits" do
    it "OrganisationsController has rate limits for search/geolocated" do
      source = controller_source(OrganisationsController)
      expect(source).to match(/limit:\s*30.*:search.*:geolocated/m).or(
        match(/limit:\s*30.*:geolocated.*:search/m)
      )
    end
  end
end

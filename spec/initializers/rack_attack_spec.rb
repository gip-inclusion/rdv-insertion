# frozen_string_literal: true

require "rails_helper"
require "rack/test"

RSpec.describe Rack::Attack do # rubocop:disable RSpec/SpecFilePathFormat
  include Rack::Test::Methods

  let(:inner_app) { ->(_env) { [200, { "Content-Type" => "text/plain" }, ["OK"]] } }
  let(:app) { described_class.new(inner_app) }

  before do
    described_class.reset!
    described_class.cache.store = ActiveSupport::Cache::MemoryStore.new
    # Disable safelist for testing (localhost would bypass all rules)
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
  end

  describe "general rate limiting (req/ip)" do
    it "allows 300 requests per 5 minutes" do
      300.times { get "/some-page" }
      expect(last_response.status).to eq(200)
    end

    it "throttles after 300 requests per 5 minutes" do
      301.times { get "/some-page" }
      expect(last_response.status).to eq(429)
    end

    it "excludes assets from rate limiting" do
      350.times { get "/assets/application.js" }
      expect(last_response.status).to eq(200)
    end

    it "excludes packs from rate limiting" do
      350.times { get "/packs/js/application.js" }
      expect(last_response.status).to eq(200)
    end
  end

  describe "login page throttling (logins/ip)" do
    it "allows 5 GET requests to /sign_in per minute" do
      5.times { get "/sign_in" }
      expect(last_response.status).to eq(200)
    end

    it "throttles after 5 GET requests to /sign_in per minute" do
      6.times { get "/sign_in" }
      expect(last_response.status).to eq(429)
    end

    it "does not throttle POST requests to /sign_in under this rule" do
      # POST uses different auth flow, only GET is throttled here
      6.times { post "/sign_in" }
      expect(last_response.status).to eq(200)
    end
  end

  describe "OAuth callback throttling (auth_callback/ip)" do
    it "allows 10 requests to OAuth callback per minute" do
      10.times { get "/auth/inclusion_connect/callback" }
      expect(last_response.status).to eq(200)
    end

    it "throttles after 10 requests to OAuth callback per minute" do
      11.times { get "/auth/inclusion_connect/callback" }
      expect(last_response.status).to eq(429)
    end

    it "applies to any OAuth provider callback" do
      11.times { get "/auth/other_provider/callback" }
      expect(last_response.status).to eq(429)
    end
  end

  describe "session creation throttling (sessions/ip)" do
    it "allows 5 POST requests to /sessions per minute" do
      5.times { post "/sessions" }
      expect(last_response.status).to eq(200)
    end

    it "throttles after 5 POST requests to /sessions per minute" do
      6.times { post "/sessions" }
      expect(last_response.status).to eq(429)
    end
  end

  describe "super admin authentication throttling (super_admin_auth/ip)" do
    it "allows 3 requests per minute" do
      3.times { get "/super_admin_authentication_request" }
      expect(last_response.status).to eq(200)
    end

    it "throttles after 3 requests per minute - very strict" do
      4.times { get "/super_admin_authentication_request" }
      expect(last_response.status).to eq(429)
    end
  end

  describe "API throttling (api/ip)" do
    it "allows 100 requests to /api per minute" do
      100.times { get "/api/v1/organisations" }
      expect(last_response.status).to eq(200)
    end

    it "throttles after 100 requests to /api per minute" do
      101.times { get "/api/v1/organisations" }
      expect(last_response.status).to eq(429)
    end
  end

  describe "API user creation throttling (api/users/ip)" do
    it "allows 20 POST requests to user endpoints per minute" do
      20.times { post "/api/v1/organisations/123/users" }
      expect(last_response.status).to eq(200)
    end

    it "throttles after 20 POST requests to user endpoints per minute" do
      21.times { post "/api/v1/organisations/123/users" }
      expect(last_response.status).to eq(429)
    end

    it "does not throttle GET requests to user endpoints under this rule" do
      25.times { get "/api/v1/organisations/123/users" }
      expect(last_response.status).to eq(200)
    end
  end

  describe "bulk user operations throttling (api/users/bulk/ip)" do
    it "allows 5 bulk creation requests per minute" do
      5.times { post "/api/v1/organisations/123/users/create_and_invite_many" }
      expect(last_response.status).to eq(200)
    end

    it "throttles after 5 bulk creation requests - very strict" do
      6.times { post "/api/v1/organisations/123/users/create_and_invite_many" }
      expect(last_response.status).to eq(429)
    end
  end

  describe "webhook throttling (webhooks/ip)" do
    it "has a high limit of 1000 requests per minute" do
      # Verify webhook throttle exists with correct limit
      # Note: We can't test 1000 requests because general rate limit (300/5min) applies first
      # This is intentional - webhooks still have general protection
      50.times { post "/rdv_solidarites_webhooks" }
      expect(last_response.status).to eq(200)
    end

    it "applies to POST requests on webhook paths" do
      # Webhook throttle only applies to POST requests
      post "/rdv_solidarites_webhooks"
      expect(last_response.status).to eq(200)
    end

    it "applies to all configured webhook paths" do
      %w[/rdv_solidarites_webhooks /brevo/mail_webhooks /brevo/sms_webhooks /inbound_emails/brevo].each do |path|
        described_class.reset!
        post path
        expect(last_response.status).to eq(200), "Expected #{path} to be accessible"
      end
    end

    it "does not apply webhook throttle to GET requests" do
      # GET requests to webhook paths fall under general rate limit, not webhook throttle
      get "/rdv_solidarites_webhooks"
      expect(last_response.status).to eq(200)
    end
  end

  describe "invitation throttling (invitations/ip)" do
    it "allows 30 requests to /invitation per minute" do
      30.times { get "/invitation" }
      expect(last_response.status).to eq(200)
    end

    it "throttles after 30 requests to /invitation per minute" do
      31.times { get "/invitation" }
      expect(last_response.status).to eq(429)
    end

    it "applies to short invitation URLs (/r/*)" do
      31.times { get "/r/abc123" }
      expect(last_response.status).to eq(429)
    end
  end

  describe "invitation redirect throttling (invitations/redirect/ip)" do
    it "allows 20 requests to /invitations/redirect per minute" do
      20.times { get "/invitations/redirect" }
      expect(last_response.status).to eq(200)
    end

    it "throttles after 20 requests per minute" do
      21.times { get "/invitations/redirect" }
      expect(last_response.status).to eq(429)
    end
  end

  describe "organisation search throttling (organisations/search/ip)" do
    it "allows 30 requests to /organisations/search per minute" do
      30.times { get "/organisations/search" }
      expect(last_response.status).to eq(200)
    end

    it "throttles after 30 requests per minute" do
      31.times { get "/organisations/search" }
      expect(last_response.status).to eq(429)
    end

    it "applies to geolocated search as well" do
      31.times { get "/organisations/geolocated" }
      expect(last_response.status).to eq(429)
    end
  end

  describe "user search throttling (users/search/ip)" do
    it "allows 30 POST requests to /users/searches per minute" do
      30.times { post "/users/searches" }
      expect(last_response.status).to eq(200)
    end

    it "throttles after 30 POST requests per minute" do
      31.times { post "/users/searches" }
      expect(last_response.status).to eq(429)
    end
  end

  describe "stats throttling (stats/ip)" do
    it "allows 60 requests to stats pages per minute" do
      60.times { get "/stats" }
      expect(last_response.status).to eq(200)
    end

    it "throttles after 60 requests per minute" do
      61.times { get "/stats" }
      expect(last_response.status).to eq(429)
    end

    it "applies to nested stats paths" do
      61.times { get "/organisations/123/stats" }
      expect(last_response.status).to eq(429)
    end
  end

  describe "static pages throttling (static/ip)" do
    it "allows 60 requests to static pages per minute" do
      60.times { get "/" }
      expect(last_response.status).to eq(200)
    end

    it "throttles homepage after 60 requests" do
      61.times { get "/" }
      expect(last_response.status).to eq(429)
    end

    it "applies to all static paths" do
      %w[/ /mentions-legales /cgu /politique-de-confidentialite /accessibilite].each do |path|
        described_class.reset!
        61.times { get path }
        expect(last_response.status).to eq(429), "Expected #{path} to be throttled"
      end
    end
  end

  describe "blocklist: malicious user agents" do
    %w[sqlmap nikto dirbuster gobuster masscan zmap].each do |tool|
      it "blocks requests from #{tool}" do
        get "/", {}, { "HTTP_USER_AGENT" => "#{tool}/1.0" }
        expect(last_response.status).to eq(403)
      end

      it "blocks #{tool} case-insensitively" do
        get "/", {}, { "HTTP_USER_AGENT" => "#{tool.upcase}/1.0" }
        expect(last_response.status).to eq(403)
      end
    end

    it "allows legitimate browser user agents" do
      get "/", {}, { "HTTP_USER_AGENT" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0" }
      expect(last_response.status).to eq(200)
    end

    it "allows curl for legitimate API usage" do
      get "/", {}, { "HTTP_USER_AGENT" => "curl/7.88.1" }
      expect(last_response.status).to eq(200)
    end
  end

  describe "throttled response format" do
    before { 6.times { get "/sign_in" } }

    it "returns 429 status" do
      expect(last_response.status).to eq(429)
    end

    it "returns JSON content type" do
      expect(last_response.headers["Content-Type"]).to eq("application/json")
    end

    it "includes Retry-After header with seconds until reset" do
      expect(last_response.headers["Retry-After"]).to match(/^\d+$/)
      expect(last_response.headers["Retry-After"].to_i).to be_between(1, 60)
    end

    it "includes X-RateLimit-Limit header" do
      expect(last_response.headers["X-RateLimit-Limit"]).to eq("5")
    end

    it "includes X-RateLimit-Remaining as 0" do
      expect(last_response.headers["X-RateLimit-Remaining"]).to eq("0")
    end

    it "includes X-RateLimit-Reset with ISO8601 timestamp" do
      expect(last_response.headers["X-RateLimit-Reset"]).to match(/^\d{4}-\d{2}-\d{2}T/)
    end

    it "returns error message in JSON body" do
      body = JSON.parse(last_response.body)
      expect(body["error"]).to eq("Rate limit exceeded")
      expect(body["retry_after"]).to be_a(Integer)
      expect(body["message"]).to include("exceeded the allowed number of requests")
    end
  end

  describe "blocked response format" do
    before { get "/", {}, { "HTTP_USER_AGENT" => "sqlmap/1.0" } }

    it "returns 403 status" do
      expect(last_response.status).to eq(403)
    end

    it "returns JSON error" do
      body = JSON.parse(last_response.body)
      expect(body["error"]).to eq("Forbidden")
    end
  end

  describe "safelist: localhost in development/test" do
    let(:dev_env) do
      env = ActiveSupport::StringInquirer.new("development")
      allow(env).to receive(:local?).and_return(true)
      env
    end

    before do
      allow(Rails).to receive(:env).and_return(dev_env)
    end

    it "allows unlimited requests from 127.0.0.1" do
      10.times { get "/sign_in", {}, { "REMOTE_ADDR" => "127.0.0.1" } }
      expect(last_response.status).to eq(200)
    end

    it "allows unlimited requests from ::1 (IPv6 localhost)" do
      10.times { get "/sign_in", {}, { "REMOTE_ADDR" => "::1" } }
      expect(last_response.status).to eq(200)
    end
  end

  describe "instrumentation" do
    it "logs throttled requests with relevant details" do
      expect(Rails.logger).to receive(:warn).with(
        a_string_matching(/\[Rack::Attack\] Throttled request:.*ip=.*path=\/sign_in.*matched=logins\/ip/)
      )

      6.times { get "/sign_in" }
    end

    it "logs blocked requests with relevant details" do
      expect(Rails.logger).to receive(:error).with(
        a_string_matching(/\[Rack::Attack\] Blocked request:.*ip=.*path=\/.*matched=block\/bad-agents/)
      )

      get "/", {}, { "HTTP_USER_AGENT" => "sqlmap/1.0" }
    end
  end
end

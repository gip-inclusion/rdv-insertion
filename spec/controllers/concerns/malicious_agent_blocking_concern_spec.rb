# frozen_string_literal: true

require "rails_helper"

RSpec.describe MaliciousAgentBlockingConcern do
  controller(ApplicationController) do
    include MaliciousAgentBlockingConcern # rubocop:disable RSpec/DescribedClass

    skip_before_action :authenticate_agent!

    def index
      render json: { success: true }
    end
  end

  before do
    routes.draw { get "index" => "anonymous#index" }
  end

  describe "blocking malicious user agents" do
    context "with sqlmap user agent" do
      before { request.headers["User-Agent"] = "sqlmap/1.7.2" }

      it "returns 403 Forbidden" do
        get :index
        expect(response).to have_http_status(:forbidden)
      end

      it "returns JSON error body" do
        get :index
        expect(response.parsed_body).to eq("error" => "Forbidden")
      end

      it "logs the blocked request with security context" do
        allow(Rails.logger).to receive(:error)

        get :index

        expect(Rails.logger).to have_received(:error).with(
          a_string_matching(/\[Security\].*Blocked.*ip=.*path=.*user_agent=sqlmap/)
        )
      end

      it "reports to Sentry as an error" do
        allow(Sentry).to receive(:capture_message)

        get :index

        expect(Sentry).to have_received(:capture_message).with(
          "Blocked malicious request",
          hash_including(level: :error, extra: hash_including(:ip, :path, :user_agent))
        )
      end
    end

    context "with case sensitivity" do
      it "blocks regardless of case" do
        %w[SQLMAP SqlMap sQlMaP].each do |variant|
          request.headers["User-Agent"] = "#{variant}/1.0"
          get :index
          expect(response).to have_http_status(:forbidden), "Expected #{variant} to be blocked"
        end
      end
    end

    context "with substring matching" do
      it "blocks when tool name appears anywhere in user agent" do
        request.headers["User-Agent"] = "Mozilla/5.0 (compatible; sqlmap testing)"
        get :index
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "BLOCKED_USER_AGENTS constant" do
      it "includes all known security scanning tools" do
        expected_tools = %w[sqlmap nikto nmap dirbuster gobuster masscan]
        expect(described_class::BLOCKED_USER_AGENTS).to match_array(expected_tools)
      end

      it "blocks each tool in the list" do
        described_class::BLOCKED_USER_AGENTS.each do |tool|
          request.headers["User-Agent"] = "#{tool}/1.0"
          get :index
          expect(response).to have_http_status(:forbidden), "Expected #{tool} to be blocked"
        end
      end
    end
  end

  describe "allowing legitimate requests" do
    context "with standard browser user agents" do
      [
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0.0.0",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Safari/605.1.15",
        "Mozilla/5.0 (X11; Linux x86_64; rv:121.0) Gecko/20100101 Firefox/121.0"
      ].each do |ua|
        it "allows #{ua.split.first(3).join(' ')}..." do
          request.headers["User-Agent"] = ua
          get :index
          expect(response).to have_http_status(:ok)
        end
      end
    end

    context "with API client user agents" do
      %w[curl/7.88.1 Faraday/2.0].each do |ua|
        it "allows #{ua}" do
          request.headers["User-Agent"] = ua
          get :index
          expect(response).to have_http_status(:ok)
        end
      end
    end

    context "with no user agent" do
      it "allows the request" do
        request.headers["User-Agent"] = nil
        get :index
        expect(response).to have_http_status(:ok)
      end
    end

    context "with empty user agent" do
      it "allows the request" do
        request.headers["User-Agent"] = ""
        get :index
        expect(response).to have_http_status(:ok)
      end
    end
  end
end

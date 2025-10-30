# rubocop:disable RSpec/DescribeClass
RSpec.describe "Sentry configuration" do
  describe "Sentry.init configuration" do
    it "enables auto session tracking" do
      expect(Sentry.configuration.auto_session_tracking).to be true
    end

    it "configures release with SOURCE_VERSION or fallback to development" do
      expect(Sentry.configuration.release).to eq(ENV["SOURCE_VERSION"] || "development")
    end

    it "configures environment" do
      expect(Sentry.configuration.environment).to eq(ENV["ENVIRONMENT_NAME"])
    end

    it "configures breadcrumbs loggers" do
      expect(Sentry.configuration.breadcrumbs_logger).to include(:active_support_logger, :http_logger)
    end
  end

  describe "traces_sampler" do
    let(:traces_sampler) { Sentry.configuration.traces_sampler }

    context "for Sidekiq jobs" do
      it "returns 0.0 (excluded from Apdex)" do
        sampling_context = {
          transaction_context: {
            name: "SendInvitationReminderJob",
            op: "queue.sidekiq"
          }
        }

        expect(traces_sampler.call(sampling_context)).to eq(0.0)
      end

      it "returns 0.0 for all Sidekiq jobs regardless of name" do
        sampling_context = {
          transaction_context: {
            name: "AnyRandomJob",
            op: "queue.sidekiq"
          }
        }

        expect(traces_sampler.call(sampling_context)).to eq(0.0)
      end
    end

    context "for invitations with RDV-SP availability check" do
      it "returns 0.0 for InvitationsController#create" do
        sampling_context = {
          transaction_context: {
            name: "InvitationsController#create",
            op: "http.server"
          }
        }

        expect(traces_sampler.call(sampling_context)).to eq(0.0)
      end

      it "returns 0.0 for Api::V1::UsersController#invite" do
        sampling_context = {
          transaction_context: {
            name: "Api::V1::UsersController#invite",
            op: "http.server"
          }
        }

        expect(traces_sampler.call(sampling_context)).to eq(0.0)
      end

      it "returns 0.0 for Api::V1::UsersController#create_and_invite" do
        sampling_context = {
          transaction_context: {
            name: "Api::V1::UsersController#create_and_invite",
            op: "http.server"
          }
        }

        expect(traces_sampler.call(sampling_context)).to eq(0.0)
      end
    end

    context "for normal transactions" do
      it "returns 0.05 for UsersController#index" do
        sampling_context = {
          transaction_context: {
            name: "UsersController#index",
            op: "http.server"
          }
        }

        expect(traces_sampler.call(sampling_context)).to eq(0.05)
      end

      it "returns 0.05 for OrganisationsController#index" do
        sampling_context = {
          transaction_context: {
            name: "OrganisationsController#index",
            op: "http.server"
          }
        }

        expect(traces_sampler.call(sampling_context)).to eq(0.05)
      end

      it "returns 0.05 for any unfiltered endpoint" do
        sampling_context = {
          transaction_context: {
            name: "RandomController#random_action",
            op: "http.server"
          }
        }

        expect(traces_sampler.call(sampling_context)).to eq(0.05)
      end
    end
  end

  describe "before_send hook" do
    it "is configured to filter Sidekiq arguments" do
      expect(Sentry.configuration.before_send).to be_present
    end
  end
end
# rubocop:enable RSpec/DescribeClass

describe SendPeriodicInviteJob do
  include AdminJobsAgentHelper

  subject do
    described_class.new.perform
  end

  let!(:agent) { create(:agent, email: "admin_jobs@rdv-insertion.fr") }
  let!(:rdv_solidarites_session) { admin_jobs_agent_session }

  describe "#perform" do
    subject do
      described_class.new.perform(invitation.id, configuration.id, "email", rdv_solidarites_session)
    end

    let!(:organisation) { create(:organisation) }
    let!(:configuration) do
      create(:configuration,
             organisation: organisation,
             number_of_days_between_periodic_invites: 15,
             motif_category: motif_category)
    end
    let!(:motif_category) { create(:motif_category, participation_optional: false) }
    let!(:rdv_context) { create(:rdv_context, motif_category: motif_category) }
    let!(:invitation) do
      create(
        :invitation,
        rdv_context: rdv_context,
        sent_at: 15.days.ago,
        valid_until: 1.day.ago,
        organisations: [organisation]
      )
    end

    describe "#perform" do
      before do
        allow(Invitations::SaveAndSend).to receive(:call).and_return(OpenStruct.new(success?: true))
      end

      it "duplicates previous invitation" do
        expect { subject }.to change(Invitation, :count).by(1)
        invitation = Invitation.last

        expect(invitation).to have_attributes(
          rdv_context: invitation.rdv_context,
          motif_category: invitation.motif_category,
          user: invitation.user,
          format: "email"
        )

        expect(invitation.valid_until.end_of_day).to eq(
          configuration
            .number_of_days_before_action_required
            .days
            .from_now
            .end_of_day
        )
      end

      it "sends invitation" do
        expect(Invitations::SaveAndSend).to receive(:call).once

        subject
      end
    end
  end
end

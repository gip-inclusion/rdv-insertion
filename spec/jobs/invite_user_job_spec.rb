describe InviteUserJob do
  subject do
    described_class.new.perform(
      user_id, organisation_id, invitation_attributes, motif_category.id, rdv_solidarites_session_credentials
    )
  end

  let!(:user_id) { 9999 }
  let!(:organisation_id) { 999 }
  let!(:motif_category) { create(:motif_category) }
  let!(:department) { create(:department) }
  let!(:user) { create(:user, id: user_id) }
  let!(:organisation) do
    create(:organisation, id: organisation_id, department: department)
  end
  let!(:configuration) do
    create(
      :configuration, motif_category: motif_category, number_of_days_before_action_required: 10,
                      rdv_with_referents: false, organisation: organisation
    )
  end
  let!(:rdv_solidarites_session_credentials) do
    { "client" => "someclient", "uid" => "janedoe@gouv.fr", "access_token" => "sometoken" }.symbolize_keys
  end
  let!(:invitation_format) { "sms" }
  let!(:invitation_attributes) do
    {
      format: invitation_format,
      help_phone_number: "01010101",
      motif_category_id: motif_category.id,
      rdv_solidarites_lieu_id: 444
    }
  end
  let!(:rdv_context) { create(:rdv_context, motif_category: motif_category, user: user) }
  let!(:invitation) { create(:invitation) }
  let!(:rdv_solidarites_session) { instance_double(RdvSolidaritesSession::Base) }

  describe "#perform" do
    context "when the user has not been invited yet" do
      let!(:valid_until) { Time.zone.parse("2022-04-15") }

      before do
        travel_to(Time.zone.parse("2022-04-05"))
        allow(Invitation).to receive(:new).with(
          invitation_attributes.merge(
            user: user, department: department, rdv_context: rdv_context, organisations: [organisation],
            valid_until: valid_until, rdv_with_referents: false
          )
        ).and_return(invitation)
        allow(RdvSolidaritesSessionFactory).to receive(:create_with)
          .with(**rdv_solidarites_session_credentials)
          .and_return(rdv_solidarites_session)
        allow(Invitations::SaveAndSend).to receive(:call)
          .with(
            invitation: invitation, rdv_solidarites_session: rdv_solidarites_session,
            check_creneaux_availability: false
          )
          .and_return(OpenStruct.new(success?: true))
      end

      it "instantiates an invitation" do
        expect(Invitation).to receive(:new).with(
          invitation_attributes.merge(
            user: user, department: department, rdv_context: rdv_context, organisations: [organisation],
            valid_until: valid_until, rdv_with_referents: false
          )
        )
        subject
      end

      it "invites the user" do
        expect(Invitations::SaveAndSend).to receive(:call)
          .with(
            invitation: invitation, rdv_solidarites_session: rdv_solidarites_session,
            check_creneaux_availability: false
          )
        subject
      end

      context "when it fails to send it" do
        before do
          allow(Invitations::SaveAndSend).to receive(:call)
            .with(
              invitation: invitation, rdv_solidarites_session: rdv_solidarites_session,
              check_creneaux_availability: false
            )
            .and_return(OpenStruct.new(success?: false, errors: ["Could not send invite"]))
        end

        it "raises an error" do
          expect { subject }.to raise_error(
            FailedServiceError,
            "Could not send invitation to user 9999 in InviteUserJob: [\"Could not send invite\"]"
          )
        end
      end
    end

    context "when the user has already been invited in the last 24 hours" do
      let!(:other_invitation) do
        create(:invitation, rdv_context: rdv_context, format: invitation_format, sent_at: 3.hours.ago)
      end

      it "does not invite the user" do
        expect(Invitations::SaveAndSend).not_to receive(:call)
        subject
      end
    end

    context "when no matching configuration for motif category" do
      let!(:other_motif_category) { create(:motif_category) }
      let!(:configuration) { create(:configuration, organisation: organisation, motif_category: other_motif_category) }

      it "raises an error" do
        expect(Invitations::SaveAndSend).not_to receive(:call)
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end

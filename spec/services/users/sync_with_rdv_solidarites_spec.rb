describe Users::SyncWithRdvSolidarites, type: :service do
  subject do
    described_class.call(
      rdv_solidarites_session: rdv_solidarites_session,
      organisation: organisation, user: user
    )
  end

  let!(:rdv_solidarites_organisation_id) { 1010 }
  let!(:organisation) do
    create(:organisation, rdv_solidarites_organisation_id: rdv_solidarites_organisation_id)
  end

  let!(:motif_category) { create(:motif_category) }
  let!(:configuration) { create(:configuration, organisation: organisation, motif_category: motif_category) }

  let!(:user) { create(:user, organisations: [organisation]) }

  let(:rdv_solidarites_session) { instance_double(RdvSolidaritesSession::Base) }

  describe "#call" do
    before do
      allow(user).to receive(:save).and_return(true)
      allow(UpsertRdvSolidaritesUser).to receive(:call)
        .and_return(OpenStruct.new(success?: true, rdv_solidarites_user_id: 123))
      allow(Users::AssignReferent).to receive(:call)
        .and_return(OpenStruct.new(success?: true))
    end

    it "upsert the user on Rdv Solidarites" do
      expect(UpsertRdvSolidaritesUser).to receive(:call)
        .with(
          user: user,
          organisation: organisation,
          rdv_solidarites_session: rdv_solidarites_session
        )
      subject
    end

    it "does not try to save the user in db" do
      expect(user).not_to receive(:save)
      subject
    end

    it "is a success" do
      is_a_success
    end

    context "when the upsert on rdvs fails" do
      before do
        allow(UpsertRdvSolidaritesUser).to receive(:call)
          .and_return(OpenStruct.new(errors: ["some error"], success?: false))
      end

      it "is a failure" do
        is_a_failure
      end

      it "stores the error" do
        expect(subject.errors).to eq(["some error"])
      end
    end

    context "when the user is not linked to a rdv solidarites user" do
      let!(:user) { create(:user, organisations: [organisation], rdv_solidarites_user_id: nil) }
      let!(:agent) { create(:agent, admin_role_in_organisations: [organisation]) }

      before { user.referents = [agent] }

      it "assign the rdv solidarites user id" do
        subject
        expect(user.rdv_solidarites_user_id).to eq(123)
      end

      it "assign the referents" do
        expect(Users::AssignReferent).to receive(:call)
          .with(
            user: user,
            agent: agent,
            rdv_solidarites_session: rdv_solidarites_session
          )
        subject
      end

      it "tries to save the user in db" do
        expect(user).to receive(:save)
        subject
      end

      it "is a success" do
        is_a_success
      end

      context "when the user cannot be saved in db" do
        before do
          allow(user).to receive(:save)
            .and_return(false)
          allow(user).to receive_message_chain(:errors, :full_messages, :to_sentence)
            .and_return("some error")
        end

        it "is a failure" do
          is_a_failure
        end

        it "stores the error" do
          expect(subject.errors).to eq(["some error"])
        end
      end
    end
  end
end

describe CreateApplicant, type: :service do
  subject do
    described_class.call(
      applicant_data: applicant_data, rdv_solidarites_session: rdv_solidarites_session,
      agent: agent
    )
  end

  let(:agent) { create(:agent) }

  let(:applicant_data) do
    {
      uid: "1234xyz", first_name: "john", last_name: "doe",
      address: "16 rue de la tour", email: "johndoe@example.com",
      role: "demandeur", affiliation_number: "aff123"
    }
  end
  let(:rdv_solidarites_session) do
    { client: "client", uid: "johndoe@example.com", access_token: "token" }
  end

  describe "#call" do
    let(:applicant_attributes) do
      { uid: "1234xyz", role: "demandeur", affiliation_number: "aff123", department: agent.department }
    end
    let!(:applicant) { build(:applicant, applicant_attributes) }
    let(:rdv_solidarites_client) { instance_double(RdvSolidaritesSession) }
    let(:rdv_solidarites_user) { instance_double(RdvSolidaritesUser) }

    before do
      allow(Applicant).to receive(:new)
        .and_return(applicant)
      allow(applicant).to receive(:save)
        .and_return(true)
      allow(CreateRdvSolidaritesUser).to receive(:call)
        .and_return(OpenStruct.new(success?: true, rdv_solidarites_user: rdv_solidarites_user))
      allow(rdv_solidarites_user).to receive(:id)
    end

    it "tries to create the applicant in db" do
      expect(Applicant).to receive(:new)
        .with(applicant_attributes)
      expect(applicant).to receive(:save)
      subject
    end

    context "when the applicant cannot be saved in db" do
      before do
        allow(applicant).to receive(:save)
          .and_return(false)
        allow(applicant).to receive_message_chain(:errors, :full_messages, :to_sentence)
          .and_return('some error')
      end

      it "rollbacks the transaction" do
        expect(Applicant).to receive(:transaction) do |&block|
          expect { block.call }.to raise_error(ActiveRecord::Rollback)
        end.and_return(nil)
        subject
      end

      it "is a failure" do
        is_a_failure
      end

      it "stores the error" do
        expect(subject.errors).to eq(['some error'])
      end
    end

    context "when the applicant can be saved in db" do
      let(:rdv_solidarites_user_attributes) do
        {
          first_name: "john", last_name: "doe",
          address: "16 rue de la tour", email: "johndoe@example.com",
          affiliation_number: "aff123",
          organisation_ids: [agent.rdv_solidarites_organisation_id]
        }
      end

      it "stores the applicant" do
        expect(subject.applicant).to eq(applicant)
      end

      it "tries to create a rdv solidarites user" do
        expect(CreateRdvSolidaritesUser).to receive(:call)
          .with(
            user_attributes: rdv_solidarites_user_attributes,
            rdv_solidarites_session: rdv_solidarites_session
          )
        subject
      end

      context "when the applicant is a conjoint" do
        before do
          allow(applicant).to receive(:conjoint?).and_return(true)
        end

        it "creates the user without the email" do
          expect(CreateRdvSolidaritesUser).to receive(:call)
            .with(
              user_attributes: rdv_solidarites_user_attributes.except(:email),
              rdv_solidarites_session: rdv_solidarites_session
            )
          subject
        end
      end

      context "when the rdv solidarites user creation fails" do
        before do
          allow(CreateRdvSolidaritesUser).to receive(:call)
            .and_return(OpenStruct.new(errors: ['some error'], success?: false))
        end

        it "is a failure" do
          is_a_failure
        end

        it "stores the error" do
          expect(subject.errors).to eq(['some error'])
        end

        it "rollback the transaction" do
          expect(Applicant).to receive(:transaction) do |&block|
            expect { block.call }.to raise_error(ActiveRecord::Rollback)
          end.and_return(nil)
          subject
        end
      end

      context "when the rdv solidarites user creation succeeds" do
        let(:augmented_applicant) { instance_double(AugmentedApplicant) }

        before do
          allow(rdv_solidarites_user).to receive(:id).and_return(142)
          allow(AugmentedApplicant).to receive(:new)
            .and_return(augmented_applicant)
        end

        it "stores the rdv solidarites user" do
          expect(subject.rdv_solidarites_user).to eq(rdv_solidarites_user)
        end

        it "assign the rdv solidarites user id" do
          subject
          expect(applicant.rdv_solidarites_user_id).to eq(142)
        end

        it "save the applicant" do
          expect(applicant).to receive(:save).twice
          subject
        end

        it "stores the augmented applicant" do
          expect(AugmentedApplicant).to receive(:new)
            .with(applicant, rdv_solidarites_user)
          expect(subject.augmented_applicant).to eq(augmented_applicant)
        end
      end
    end
  end
end

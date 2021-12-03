describe UpsertApplicant, type: :service do
  subject do
    described_class.call(
      applicant_data: applicant_data, rdv_solidarites_session: rdv_solidarites_session,
      organisation: organisation, applicant: applicant
    )
  end

  let(:organisation) { create(:organisation) }
  let(:applicant_data) do
    {
      uid: "1234xyz", first_name: "john", last_name: "doe",
      address: "16 rue de la tour", email: "johndoe@example.com",
      role: "demandeur", birth_date: "1989/03/17", affiliation_number: "aff123", phone_number: "+33612459567"
    }
  end
  let(:rdv_solidarites_session) do
    { client: "client", uid: "johndoe@example.com", access_token: "token" }
  end
  let(:rdv_solidarites_client) { instance_double(RdvSolidaritesSession) }

  describe "#call for create" do
    let!(:applicant_attributes) { applicant_data.merge(organisations: [organisation]) }

    let!(:applicant) { build(:applicant, applicant_attributes) }
    let!(:rdv_solidarites_user) { instance_double(RdvSolidarites::User) }

    before do
      allow(applicant).to receive(:assign_attributes)
        .and_return(true)
      allow(applicant).to receive(:save)
        .and_return(true)
      allow(RdvSolidaritesApi::UpsertUser).to receive(:call)
        .and_return(OpenStruct.new(success?: true, rdv_solidarites_user: rdv_solidarites_user))
      allow(rdv_solidarites_user).to receive(:id).and_return(nil)
    end

    it "tries to create the applicant in db" do
      expect(applicant).to receive(:assign_attributes)
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
          address: "16 rue de la tour", email: "johndoe@example.com", phone_number: "+33612459567",
          affiliation_number: "aff123", birth_date: Date.parse("1989/03/17"),
          notify_by_sms: true,
          notify_by_email: true,
          organisation_ids: [organisation.rdv_solidarites_organisation_id]
        }
      end

      it "tries to create a rdv solidarites user" do
        expect(RdvSolidaritesApi::UpsertUser).to receive(:call)
          .with(
            user_attributes: rdv_solidarites_user_attributes,
            rdv_solidarites_session: rdv_solidarites_session,
            rdv_solidarites_user_id: applicant.rdv_solidarites_user_id
          )
        subject
      end

      context "when organisation notifies customer from rdv insertion" do
        before do
          allow(organisation).to receive(:notify_applicant?).and_return(true)
        end

        it "does not notify with rdv solidarites" do
          expect(RdvSolidaritesApi::UpsertUser).to receive(:call)
            .with(
              user_attributes: rdv_solidarites_user_attributes.merge(
                notify_by_email: false, notify_by_sms: false
              ),
              rdv_solidarites_session: rdv_solidarites_session,
              rdv_solidarites_user_id: applicant.rdv_solidarites_user_id
            )
          subject
        end
      end

      context "when the applicant is a conjoint" do
        before do
          allow(applicant).to receive(:demandeur?).and_return(false)
          allow(applicant).to receive(:rdv_solidarites_user_id?).and_return(false)
        end

        it "creates the user without the email" do
          expect(RdvSolidaritesApi::UpsertUser).to receive(:call)
            .with(
              user_attributes: rdv_solidarites_user_attributes.except(:email),
              rdv_solidarites_session: rdv_solidarites_session,
              rdv_solidarites_user_id: applicant.rdv_solidarites_user_id
            )
          subject
        end
      end

      context "when the rdv solidarites user creation fails" do
        before do
          allow(RdvSolidaritesApi::UpsertUser).to receive(:call)
            .and_return(OpenStruct.new(errors: ['some error'], success?: false))
        end

        it "is a failure" do
          is_a_failure
        end

        it "stores the error" do
          expect(subject.errors).to eq(['some error'])
        end
      end

      context "when the rdv solidarites user creation succeeds" do
        before do
          allow(applicant).to receive(:rdv_solidarites_user_id).and_return(nil)
          allow(rdv_solidarites_user).to receive(:id).and_return(17)
          allow(applicant).to receive(:update)
            .and_return(true)
        end

        it "assign the rdv solidarites user id" do
          expect(applicant).to receive(:update)
            .with(rdv_solidarites_user_id: 17)
          subject
        end

        it "save the applicant" do
          expect(applicant).to receive(:save)
          subject
        end
      end
    end
  end

  describe "#call for update" do
    let(:applicant) { create(:applicant) }

    let(:rdv_solidarites_user_attributes) do
      {
        first_name: "john", last_name: "doe",
        address: "16 rue de la tour", email: "johndoe@example.com", phone_number: "+33612459567",
        affiliation_number: "aff123", birth_date: Date.parse("1989/03/17"),
        notify_by_sms: true,
        notify_by_email: true,
        organisation_ids: [organisation.rdv_solidarites_organisation_id]
      }
    end
    let!(:rdv_solidarites_user) { instance_double(RdvSolidarites::User, id: applicant.rdv_solidarites_user_id) }

    before do
      allow(RdvSolidaritesApi::UpsertUser).to receive(:call)
        .and_return(OpenStruct.new(success?: true, rdv_solidarites_user: rdv_solidarites_user))
      allow(applicant).to receive(:id?)
        .and_return(true)
    end

    it "tries to update the applicant" do
      expect(applicant).to receive(:update).with(applicant_data)
      subject
    end

    context "when the applicant cannot be updated" do
      before do
        allow(applicant).to receive(:update)
          .and_return(false)
        allow(applicant).to receive_message_chain(:errors, :full_messages, :to_sentence)
          .and_return('some error')
      end

      it "is a failure" do
        is_a_failure
      end

      it "stores the error" do
        expect(subject.errors).to eq(['some error'])
      end
    end

    context "when the applicant can be updated" do
      it "tries to update a rdv solidarites user" do
        expect(RdvSolidaritesApi::UpsertUser).to receive(:call)
          .with(
            user_attributes: rdv_solidarites_user_attributes,
            rdv_solidarites_session: rdv_solidarites_session,
            rdv_solidarites_user_id: applicant.rdv_solidarites_user_id
          )
        subject
      end

      context "when the rdv solidarites user update fails" do
        before do
          allow(RdvSolidaritesApi::UpsertUser).to receive(:call)
            .and_return(OpenStruct.new(errors: ['some error'], success?: false))
        end

        it "is a failure" do
          is_a_failure
        end

        it "stores the error" do
          expect(subject.errors).to eq(['some error'])
        end
      end
    end
  end
end

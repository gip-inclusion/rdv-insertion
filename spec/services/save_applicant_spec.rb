describe SaveApplicant, type: :service do
  subject do
    described_class.call(
      rdv_solidarites_session: rdv_solidarites_session,
      organisation: organisation, applicant: applicant
    )
  end

  let!(:rdv_solidarites_organisation_id) { 1010 }
  let!(:rdv_solidarites_user_id) { 2020 }
  let!(:organisation) { create(:organisation, rdv_solidarites_organisation_id: rdv_solidarites_organisation_id) }
  let!(:applicant_attributes) do
    {
      uid: "1234xyz", first_name: "john", last_name: "doe",
      address: "16 rue de la tour", email: "johndoe@example.com", birth_name: "",
      role: "demandeur", birth_date: Date.new(1989, 3, 17), affiliation_number: "aff123", phone_number: "+33612459567"
    }
  end
  let!(:rdv_solidarites_user_attributes) do
    {
      first_name: "john", last_name: "doe", notify_by_sms: true, notify_by_email: true,
      address: "16 rue de la tour", email: "johndoe@example.com", birth_name: "",
      birth_date: Date.new(1989, 3, 17), affiliation_number: "aff123", phone_number: "+33612459567"
    }
  end

  let!(:configuration) { create(:configuration, organisation: organisation, notify_applicant: false) }

  let!(:applicant) do
    create(:applicant, applicant_attributes.merge(organisations: [organisation], rdv_solidarites_user_id: nil))
  end

  let(:rdv_solidarites_session) { instance_double(RdvSolidaritesSession) }

  describe "#call" do
    before do
      allow(applicant).to receive(:save).and_return(true)
      allow(applicant).to receive(:update).and_return(true)
      allow(UpsertRdvSolidaritesUser).to receive(:call)
        .and_return(OpenStruct.new(success?: true, rdv_solidarites_user_id: rdv_solidarites_user_id))
    end

    it "tries to save the applicant in db" do
      expect(applicant).to receive(:save)
      subject
    end

    it "upserts a rdv solidarites user" do
      expect(UpsertRdvSolidaritesUser).to receive(:call)
        .with(
          rdv_solidarites_session: rdv_solidarites_session,
          rdv_solidarites_organisation_id: rdv_solidarites_organisation_id,
          rdv_solidarites_user_attributes: rdv_solidarites_user_attributes,
          rdv_solidarites_user_id: nil
        )
      subject
    end

    it "assign the rdv solidarites user id" do
      expect(applicant).to receive(:update)
        .with(rdv_solidarites_user_id: rdv_solidarites_user_id)
      subject
    end

    it "is a success" do
      is_a_success
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

    context "when organisation notifies customer from rdv insertion" do
      let!(:configuration) { create(:configuration, organisation: organisation, notify_applicant: true) }

      it "does not notify with rdv solidarites user" do
        expect(UpsertRdvSolidaritesUser).to receive(:call)
          .with(
            rdv_solidarites_user_attributes: rdv_solidarites_user_attributes.merge(
              notify_by_email: false, notify_by_sms: false
            ),
            rdv_solidarites_session: rdv_solidarites_session,
            rdv_solidarites_organisation_id: rdv_solidarites_organisation_id,
            rdv_solidarites_user_id: nil
          )
        subject
      end
    end

    context "when the applicant is a conjoint" do
      before { applicant.update!(role: "conjoint") }

      it "creates the user without the email" do
        expect(UpsertRdvSolidaritesUser).to receive(:call)
          .with(
            rdv_solidarites_user_attributes: rdv_solidarites_user_attributes.except(:email),
            rdv_solidarites_session: rdv_solidarites_session,
            rdv_solidarites_organisation_id: rdv_solidarites_organisation_id,
            rdv_solidarites_user_id: nil
          )
        subject
      end
    end

    context "when the rdv solidarites user upsert fails" do
      before do
        allow(UpsertRdvSolidaritesUser).to receive(:call)
          .and_return(OpenStruct.new(errors: ['some error'], success?: false))
      end

      it "is a failure" do
        is_a_failure
      end

      it "stores the error" do
        expect(subject.errors).to eq(['some error'])
      end
    end

    context "when the applicant update fails" do
      before do
        allow(applicant).to receive(:update).and_return(false)
        allow(applicant).to receive_message_chain(:errors, :full_messages, :to_sentence)
          .and_return('update error')
      end

      it "is a failure" do
        is_a_failure
      end

      it "stores the error" do
        expect(subject.errors).to eq(['update error'])
      end
    end

    context "when the applicant is already linked to a rdv solidarites user" do
      let!(:applicant) do
        create(:applicant, applicant_attributes
          .merge(
            organisations: [organisation], rdv_solidarites_user_id: rdv_solidarites_user_id
          ))
      end

      it "does not assign the user id" do
        expect(applicant).not_to receive(:update)
        subject
      end
    end
  end
end

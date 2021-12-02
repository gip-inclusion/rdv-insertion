describe UpdateApplicant, type: :service do
  subject do
    described_class.call(
      applicant: applicant, applicant_data: applicant_data,
      rdv_solidarites_session: rdv_solidarites_session
    )
  end

  let(:organisation) { create(:organisation) }
  let(:applicant) { create(:applicant) }
  let!(:birth_date) { "1981-07-11" }
  let(:applicant_data) do
    {
      first_name: "Alain", last_name: "Deloin",
      address: "10 rue du près", email: "alain@deloin.fr",
      role: "conjoint", affiliation_number: "0987",
      birth_date: birth_date, phone_number: "0123456789"
    }
  end
  let!(:phone_number_formatted) { "+33123456789" }
  let(:rdv_solidarites_session) do
    { client: "client", uid: "johndoe@example.com", access_token: "token" }
  end

  describe "#call" do
    let!(:rdv_solidarites_user_attributes) do
      applicant_data.except(:role)
    end
    let(:rdv_solidarites_client) { instance_double(RdvSolidaritesSession) }
    let!(:rdv_solidarites_user) { instance_double(RdvSolidarites::User, id: applicant.rdv_solidarites_user_id) }
    let!(:update_applicant_params) do
      {
        first_name: "Alain", last_name: "Deloin",
        address: "10 rue du près", email: "alain@deloin.fr",
        role: "conjoint", affiliation_number: "0987",
        birth_date: "1981-07-11", phone_number: "0123456789"
      }
    end

    before do
      allow(RdvSolidaritesApi::UpdateUser).to receive(:call)
        .and_return(OpenStruct.new(success?: true, rdv_solidarites_user: rdv_solidarites_user))
    end

    it "tries to update the applicant" do
      expect(applicant).to receive(:update).with(update_applicant_params)
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
        expect(RdvSolidaritesApi::UpdateUser).to receive(:call)
          .with(
            user_attributes: rdv_solidarites_user_attributes.merge(
              phone_number: phone_number_formatted, birth_date: birth_date.to_date
            ),
            rdv_solidarites_session: rdv_solidarites_session,
            rdv_solidarites_user_id: applicant.rdv_solidarites_user_id
          )
        subject
      end

      context "when the rdv solidarites user update fails" do
        before do
          allow(RdvSolidaritesApi::UpdateUser).to receive(:call)
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

describe UpdateApplicant, type: :service do
  subject do
    described_class.call(
      applicant_id: applicant_id, applicant_data: applicant_data,
      rdv_solidarites_session: rdv_solidarites_session,
      rdv_solidarites_user_id: rdv_solidarites_user_id
    )
  end

  let(:organisation) { create(:organisation) }
  let(:applicant) { create(:applicant) }
  let(:applicant_id) { applicant.id }
  let(:rdv_solidarites_user_id) { applicant.rdv_solidarites_user_id }
  let(:applicant_data) do
    {
      first_name: "Alain", last_name: "Deloin",
      address: "10 rue du près", email: "alain@deloin.fr",
      role: "conjoint", affiliation_number: "0987",
      'birth_date(1i)': "1981", 'birth_date(2i)': "07",
      'birth_date(3i)': "11", phone_number_formatted: "0123456789"
    }
  end
  let(:rdv_solidarites_session) do
    { client: "client", uid: "johndoe@example.com", access_token: "token" }
  end

  describe "#call" do
    let!(:rdv_solidarites_user_attributes) do
      applicant_data.except(:'birth_date(1i)', :'birth_date(2i)', :'birth_date(3i)', :phone_number_formatted, :role)
                    .merge(birth_date: "#{applicant_data[:'birth_date(1i)']}/
      #{applicant_data[:'birth_date(2i)']}/#{applicant_data[:'birth_date(3i)']}")
                    .merge(phone_number: applicant_data[:phone_number_formatted])
    end
    let(:rdv_solidarites_client) { instance_double(RdvSolidaritesSession) }
    let!(:rdv_solidarites_user) { instance_double(RdvSolidarites::User, id: rdv_solidarites_user_id) }
    let!(:update_applicant_params) do
      {
        first_name: "Alain", last_name: "Deloin",
        address: "10 rue du près", email: "alain@deloin.fr",
        role: "conjoint", affiliation_number: "0987",
        birth_date: "1981-07-11", phone_number_formatted: "+33123456789"
      }
    end

    before do
      allow(RdvSolidaritesApi::UpdateUser).to receive(:call)
        .and_return(OpenStruct.new(success?: true, rdv_solidarites_user: rdv_solidarites_user))
      allow(rdv_solidarites_user).to receive(:attributes)
        .and_return(
          { first_name: "Alain", last_name: "Deloin",
            address: "10 rue du près", email: "alain@deloin.fr",
            affiliation_number: "0987", birth_date: "1981-07-11",
            phone_number_formatted: "+33123456789" }
        )
      allow(applicant).to receive(:update).and_return(true)
    end

    # it "tries to update the applicant" do
    #   expect(applicant).to receive(:update).with(update_applicant_params)
    #   subject
    # end

    # context "when the applicant cannot be updated" do
    #   before do
    #     allow(applicant).to receive(:update)
    #       .and_return(false)
    #     allow(applicant).to receive_message_chain(:errors, :full_messages, :to_sentence)
    #       .and_return('some error')
    #   end

    #   it "is a failure" do
    #     is_a_failure
    #   end

    #   it "stores the error" do
    #     expect(subject.errors).to eq(['some error'])
    #   end
    # end

    context "when the applicant can be updated" do
      it "stores the applicant" do
        expect(subject.applicant).to eq(applicant)
      end

      it "tries to update a rdv solidarites user" do
        expect(RdvSolidaritesApi::UpdateUser).to receive(:call)
          .with(
            user_attributes: rdv_solidarites_user_attributes,
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

      context "when the rdv solidarites user update succeeds" do
        it "updates the first name" do
          subject
          expect(subject.applicant.first_name).to eq("Alain")
        end

        it "updates the last name" do
          subject
          expect(subject.applicant.last_name).to eq("Deloin")
        end

        it "updates the email" do
          subject
          expect(subject.applicant.email).to eq("alain@deloin.fr")
        end

        it "updates the address" do
          subject
          expect(subject.applicant.address).to eq("10 rue du près")
        end

        it "updates the affiliation number" do
          subject
          expect(subject.applicant.affiliation_number).to eq("0987")
        end

        it "updates the birth date" do
          subject
          expect(subject.applicant.birth_date).to eq(Date.parse("1981/07/11"))
        end

        it "updates the role" do
          subject
          expect(subject.applicant.role).to eq("conjoint")
        end

        it "updates the phone number formatted" do
          subject
          expect(subject.applicant.phone_number_formatted).to eq("+33123456789")
        end

        it "stores the applicant" do
          expect(subject.applicant).to eq(applicant)
        end
      end
    end
  end
end

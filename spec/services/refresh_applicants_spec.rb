describe RefreshApplicants, type: :service do
  subject do
    described_class.call(
      applicants: applicants,
      rdv_solidarites_session: rdv_solidarites_session,
      rdv_solidarites_organisation_id: rdv_solidarites_organisation_id
    )
  end

  let(:rdv_solidarites_user_id) { 51 }
  let(:applicant) do
    create(
      :applicant, first_name: "Bernard", last_name: "Lama",
                  rdv_solidarites_user_id: rdv_solidarites_user_id
    )
  end
  let!(:rdv_solidarites_organisation_id) { 42 }
  let(:applicants) { [applicant] }
  let(:rdv_solidarites_session) do
    { client: "client", uid: "johndoe@example.com", access_token: "token" }
  end

  describe "#call" do
    let(:rdv_solidarites_user) do
      RdvSolidarites::User.new(
        first_name: "Bernard", last_name: "Lamo", email: "bernardlamo@gmail.com"
      )
    end

    before do
      allow(RetrieveRdvSolidaritesResources).to receive(:call)
        .and_return(
          OpenStruct.new(
            success?: true, users: [rdv_solidarites_user]
          )
        )
      allow(rdv_solidarites_user).to receive(:id)
        .and_return(rdv_solidarites_user_id)
    end

    context "when no applicants are passed" do
      let(:applicants) { [] }

      it "is a success" do
        is_a_success
      end

      it "does not retrieve rdv solidarites users" do
        expect(RetrieveRdvSolidaritesResources).not_to receive(:call)
        subject
      end
    end

    context "when applicants are passed" do
      it "tries to retrieve the rdv solidarites users" do
        expect(RetrieveRdvSolidaritesResources).to receive(:call)
          .with(
            additional_args: [51], rdv_solidarites_session: rdv_solidarites_session,
            organisation_id: rdv_solidarites_organisation_id, resource_name: "users"
          )
        subject
      end

      context "when it retrieves users" do
        it "is a success" do
          is_a_success
        end

        it "updates the applicant with rdv solidarites attributes" do
          subject
          expect(applicant.last_name).to eq("Lamo")
          expect(applicant.email).to eq("bernardlamo@gmail.com")
        end
      end

      context "when it does not retrieve users" do
        before do
          allow(RetrieveRdvSolidaritesResources).to receive(:call)
            .and_return(OpenStruct.new(success?: false, errors: ['some error']))
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

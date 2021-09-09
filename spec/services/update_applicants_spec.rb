describe UpdateApplicants, type: :service do
  subject do
    described_class.call(
      applicants: applicants,
      rdv_solidarites_session: rdv_solidarites_session,
      page: page
    )
  end

  let(:rdv_solidarites_user_id) { 51 }
  let(:applicant) do
    create(
      :applicant, first_name: "Bernard", last_name: "Lama",
                  rdv_solidarites_user_id: rdv_solidarites_user_id, department: department
    )
  end
  let(:department) { create(:department, rdv_solidarites_organisation_id: 42) }
  let(:applicants) { [applicant] }
  let(:rdv_solidarites_session) do
    { client: "client", uid: "johndoe@example.com", access_token: "token" }
  end

  let(:page) { 1 }

  describe "#call" do
    let(:rdv_solidarites_user) do
      RdvSolidaritesUser.new(
        first_name: "Bernard", last_name: "Lamo", email: "bernardlamo@gmail.com"
      )
    end

    before do
      allow(RetrieveRdvSolidaritesUsers).to receive(:call)
        .and_return(
          OpenStruct.new(
            success?: true, rdv_solidarites_users: [rdv_solidarites_user],
            next_page: 2
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
        expect(RetrieveRdvSolidaritesUsers).not_to receive(:call)
        subject
      end
    end

    context "when applicants are passed" do
      it "tries to retrieve the rdv solidarites users" do
        expect(RetrieveRdvSolidaritesUsers).to receive(:call)
          .with(
            ids: [51], rdv_solidarites_session: rdv_solidarites_session,
            organisation_id: 42, page: page
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

        it "stores the next page" do
          expect(subject.next_page).to eq(2)
        end
      end

      context "when it does not retrieve users" do
        before do
          allow(RetrieveRdvSolidaritesUsers).to receive(:call)
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

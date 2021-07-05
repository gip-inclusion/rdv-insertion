describe RetrieveAugmentedApplicants, type: :service do
  subject do
    described_class.call(
      applicants: applicants,
      rdv_solidarites_session: rdv_solidarites_session,
      page: page
    )
  end

  let(:rdv_solidarites_user_id) { 51 }
  let(:applicant) { create(:applicant, rdv_solidarites_user_id: rdv_solidarites_user_id, department: department) }
  let(:department) { create(:department, rdv_solidarites_organisation_id: 42) }
  let(:applicants) { [applicant] }
  let(:rdv_solidarites_session) do
    { client: "client", uid: "johndoe@example.com", access_token: "token" }
  end

  let(:page) { 1 }

  describe "#call" do
    let(:rdv_solidarites_user) { instance_double(RdvSolidaritesUser) }

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

      it "does store any augmented applicants" do
        expect(subject.augmented_applicants).to eq([])
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

      context "when it retrieves usersr" do
        let(:augmented_applicant) { instance_double(AugmentedApplicant) }

        before do
          allow(AugmentedApplicant).to receive(:new)
            .with(applicant, rdv_solidarites_user)
            .and_return(augmented_applicant)
        end

        it "is a success" do
          is_a_success
        end

        it "stores the augmented applicants" do
          expect(subject.augmented_applicants).to eq([augmented_applicant])
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

        it "does not store augmented applicants" do
          expect(subject.augmented_applicants).to eq([])
        end
      end
    end
  end
end

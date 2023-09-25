describe Users::Save, type: :service do
  subject do
    described_class.call(
      rdv_solidarites_session: rdv_solidarites_session,
      organisation: organisation, user: user
    )
  end

  let!(:rdv_solidarites_organisation_id) { 1010 }
  let!(:rdv_solidarites_user_id) { 2020 }
  let!(:organisation) do
    create(:organisation, rdv_solidarites_organisation_id: rdv_solidarites_organisation_id)
  end
  let!(:user_attributes) do
    {
      uid: "1234xyz", first_name: "john", last_name: "doe",
      address: "16 rue de la tour", email: "johndoe@example.com", birth_name: "",
      role: "demandeur", birth_date: Date.new(1989, 3, 17), affiliation_number: "aff123", phone_number: "+33612459567"
    }
  end
  let!(:rdv_solidarites_user_attributes) do
    {
      first_name: "john", last_name: "doe",
      address: "16 rue de la tour", email: "johndoe@example.com", birth_name: "",
      birth_date: Date.new(1989, 3, 17), affiliation_number: "aff123", phone_number: "+33612459567"
    }
  end

  let!(:motif_category) { create(:motif_category) }
  let!(:configuration) { create(:configuration, organisation: organisation, motif_category: motif_category) }

  let!(:user) do
    create(:user, user_attributes.merge(organisations: [organisation], rdv_solidarites_user_id: nil))
  end

  let(:rdv_solidarites_session) { instance_double(RdvSolidaritesSession::Base) }

  describe "#call" do
    before do
      allow(user).to receive(:save).and_return(true)
      allow(Users::Validate).to receive(:call)
        .with(user: user).and_return(OpenStruct.new(success?: true))
      allow(UpsertRdvSolidaritesUser).to receive(:call)
        .and_return(OpenStruct.new(success?: true, rdv_solidarites_user_id: rdv_solidarites_user_id))
    end

    it "tries to save the user in db" do
      expect(user).to receive(:save)
      subject
    end

    it "upserts a rdv solidarites user" do
      expect(UpsertRdvSolidaritesUser).to receive(:call)
        .with(
          rdv_solidarites_session: rdv_solidarites_session,
          rdv_solidarites_organisation_id: rdv_solidarites_organisation_id,
          rdv_solidarites_user_attributes: rdv_solidarites_user_attributes.except(:birth_name),
          rdv_solidarites_user_id: nil
        )
      subject
    end

    it "assign the rdv solidarites user id" do
      subject
      expect(user.rdv_solidarites_user_id).not_to be_nil
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

    context "when the user has a department_internal_id but no role" do
      before { user.update!(role: nil, department_internal_id: 666) }

      it "creates the user normally, with the email" do
        expect(UpsertRdvSolidaritesUser).to receive(:call)
          .with(
            rdv_solidarites_user_attributes: rdv_solidarites_user_attributes.except(:birth_name),
            rdv_solidarites_session: rdv_solidarites_session,
            rdv_solidarites_organisation_id: rdv_solidarites_organisation_id,
            rdv_solidarites_user_id: nil
          )
        subject
      end
    end

    context "when the user is a conjoint" do
      before { user.update!(role: "conjoint") }

      it "creates the user without the email" do
        expect(UpsertRdvSolidaritesUser).to receive(:call)
          .with(
            rdv_solidarites_user_attributes: rdv_solidarites_user_attributes.except(:email, :birth_name),
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
          .and_return(OpenStruct.new(errors: ["some error"], success?: false))
      end

      it "is a failure" do
        is_a_failure
      end

      it "stores the error" do
        expect(subject.errors).to eq(["some error"])
      end
    end

    context "when the user update fails" do
      before do
        allow(user).to receive(:save).and_return(false)
        allow(user).to receive_message_chain(:errors, :full_messages, :to_sentence)
          .and_return("update error")
      end

      it "is a failure" do
        is_a_failure
      end

      it "stores the error" do
        expect(subject.errors).to eq(["update error"])
      end
    end

    context "when the validation service fails" do
      before do
        allow(Users::Validate).to receive(:call)
          .with(user: user).and_return(OpenStruct.new(success?: false, errors: ["invalid user"]))
      end

      it "is a failure" do
        is_a_failure
      end

      it "stores the error" do
        expect(subject.errors).to eq(["invalid user"])
      end
    end

    context "when the user is already linked to a rdv solidarites user" do
      let!(:user) do
        create(:user, user_attributes
          .merge(
            organisations: [organisation], rdv_solidarites_user_id: rdv_solidarites_user_id
          ))
      end

      it "does not reassign the user id" do
        expect(user).to receive(:save).at_most(1).time
        subject
      end
    end
  end
end

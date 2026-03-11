describe AlertUserAddedToAnotherDepartmentJob do
  subject { described_class.new.perform(user.id, newly_added_organisation.id) }

  let(:department) { create(:department) }
  let(:newly_added_organisation) { create(:organisation, department: department) }
  let(:user) { create(:user, organisations: [newly_added_organisation]) }

  describe "#perform" do
    context "when the user only belongs to the new department" do
      it "does not send alerts" do
        expect(SlackClient).not_to receive(:send_to_private_channel)
        expect(Sentry).not_to receive(:capture_message)
        subject
      end
    end

    context "when the user belongs to another organisation in the same department" do
      let(:other_org_same_department) { create(:organisation, department: department) }
      let(:user) { create(:user, organisations: [newly_added_organisation, other_org_same_department]) }

      it "does not send alerts" do
        expect(SlackClient).not_to receive(:send_to_private_channel)
        expect(Sentry).not_to receive(:capture_message)
        subject
      end
    end

    context "when the user belongs to an organisation in another department" do
      let(:other_department) { create(:department) }
      let(:other_org) { create(:organisation, department: other_department) }
      let(:user) { create(:user, organisations: [newly_added_organisation, other_org]) }

      it "sends an alert to slack and Sentry" do
        expect(SlackClient).to receive(:send_to_private_channel).with(
          "⚠️ L'usager #{user.id} vient d'être ajouté à l'organisation #{newly_added_organisation.name} " \
          "(département #{department.number}) alors qu'il appartient déjà " \
          "à d'autres départements: #{other_department.number}"
        )
        expect(Sentry).to receive(:capture_message)
        subject
      end
    end

    context "when the user does not exist" do
      it "does not send alerts" do
        expect(SlackClient).not_to receive(:send_to_private_channel)
        expect(Sentry).not_to receive(:capture_message)
        described_class.new.perform(0, newly_added_organisation.id)
      end
    end

    context "when the organisation does not exist" do
      it "does not send alerts" do
        expect(SlackClient).not_to receive(:send_to_private_channel)
        expect(Sentry).not_to receive(:capture_message)
        described_class.new.perform(user.id, 0)
      end
    end
  end
end

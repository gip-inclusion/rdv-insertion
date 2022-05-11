describe Stat do
  subject do
    described_class.new(applicants: Applicant.all, agents: Agent.all, invitations: Invitation.all,
                        rdvs: Rdv.all, rdv_contexts: RdvContext.all, organisations: Organisation.all)
  end

  let!(:configuration) { create(:configuration, notify_applicant: false) }
  let!(:configuration_notify) { create(:configuration, notify_applicant: true) }

  let!(:relevant_organisation) { create(:organisation, configurations: [configuration]) }
  let!(:irrelevant_organisation) { create(:organisation, configurations: [configuration_notify]) }

  let!(:rdv_context_orientation) do
    create(:rdv_context, context: "rsa_orientation", created_at: DateTime.new(2022, 4, 4, 10, 0))
  end
  let!(:rdv_context_orientation_platform) do
    create(:rdv_context, context: "rsa_orientation_on_phone_platform", created_at: DateTime.new(2022, 5, 7, 10, 0))
  end
  let!(:rdv_context_accompagnement) { create(:rdv_context, context: "rsa_accompagnement") }
  let!(:empty_rdv_context) { create(:rdv_context, context: "rsa_accompagnement") }

  let!(:invitation) do
    create(:invitation, sent_at: DateTime.new(2022, 4, 4, 10, 0), rdv_context: rdv_context_orientation)
  end
  let!(:invitation2) do
    create(:invitation, sent_at: DateTime.new(2022, 5, 7, 10, 0), rdv_context: rdv_context_orientation_platform)
  end
  let!(:invitation_not_sended) { create(:invitation, sent_at: nil) }

  let!(:orientation_rdv) do
    create(:rdv, rdv_contexts: [rdv_context_orientation],
                 created_at: DateTime.new(2022, 4, 7, 10, 0),
                 starts_at: DateTime.new(2022, 4, 8, 10, 0),
                 status: "seen")
  end
  let!(:orientation_rdv2) do
    create(:rdv, rdv_contexts: [rdv_context_orientation],
                 created_at: DateTime.new(2022, 5, 2, 10, 0),
                 starts_at: DateTime.new(2022, 5, 7, 10, 0),
                 status: "noshow")
  end
  let!(:orientation_platform_rdv) do
    create(:rdv, rdv_contexts: [rdv_context_orientation_platform],
                 created_at: DateTime.new(2022, 5, 8, 10, 0),
                 starts_at: DateTime.new(2022, 5, 11, 10, 0))
  end
  let!(:accompagnement_rdv) { create(:rdv, rdv_contexts: [rdv_context_accompagnement]) }
  let!(:irrelevant_rdv) { create(:rdv) }
  let!(:irrelevant_rdv2) { create(:rdv) }
  let!(:irrelevant_rdv3) { create(:rdv) }

  let!(:relevant_applicant) do
    create(:applicant, organisations: [relevant_organisation],
                       rdvs: [orientation_rdv, orientation_platform_rdv, accompagnement_rdv],
                       rdv_contexts: [rdv_context_orientation],
                       rights_opening_date: DateTime.new(2022, 4, 2, 10, 0),
                       created_at: DateTime.new(2022, 4, 1, 10, 0))
  end
  let!(:relevant_orientation_platform_applicant) do
    create(:applicant, organisations: [relevant_organisation, irrelevant_organisation],
                       rdvs: [orientation_rdv2],
                       rdv_contexts: [rdv_context_orientation_platform, empty_rdv_context],
                       rights_opening_date: 35.days.ago)
  end
  let!(:irrelevant_applicant) do
    create(:applicant, organisations: [irrelevant_organisation],
                       rdvs: [irrelevant_rdv],
                       rdv_contexts: [rdv_context_accompagnement])
  end
  let!(:irrelevant_applicant2) do
    create(:applicant, organisations: [relevant_organisation], status: "deleted", rdvs: [irrelevant_rdv2])
  end
  let!(:irrelevant_applicant3) do
    create(:applicant, organisations: [relevant_organisation], is_archived: true, rdvs: [irrelevant_rdv3])
  end

  describe "#relevant_organisations" do
    context "when an organisation does not notify applicants" do
      it "is not filtered" do
        expect(subject.relevant_organisations).to include(relevant_organisation)
      end
    end

    context "when an organisation notifies applicants" do
      it "is filtered" do
        expect(subject.relevant_organisations).not_to include(irrelevant_organisation)
      end
    end
  end

  describe "#relevant_applicants" do
    context "when an applicant is in the scope" do
      it "is not filtered" do
        expect(subject.relevant_applicants).to include(relevant_applicant)
        expect(subject.relevant_applicants).to include(relevant_orientation_platform_applicant)
      end
    end

    context "when an applicant does not belong to a relevant organisation" do
      it "is filtered" do
        expect(subject.relevant_applicants).not_to include(irrelevant_applicant)
      end
    end

    context "when an applicant is deleted or archived" do
      it "is filtered" do
        expect(subject.relevant_applicants).not_to include(irrelevant_applicant2)
        expect(subject.relevant_applicants).not_to include(irrelevant_applicant3)
      end
    end
  end

  describe "#relevant_agents" do
    context "when an agent belongs to rdv-insertion" do
      let!(:relevant_agent) { create(:agent) }
      let!(:irrelevant_agent) { create(:agent, email: "quentin.blanc@beta.gouv.fr") }

      it "is filtered" do
        expect(subject.relevant_agents).to include(relevant_agent)
        expect(subject.relevant_agents).not_to include(irrelevant_agent)
      end
    end
  end

  describe "#relevant_rdvs" do
    context "when a rdv belongs to a relevant applicant" do
      it "is not filtered" do
        expect(subject.relevant_rdvs).to include(orientation_rdv)
        expect(subject.relevant_rdvs).to include(orientation_platform_rdv)
        expect(subject.relevant_rdvs).to include(accompagnement_rdv)
        expect(subject.relevant_rdvs).to include(orientation_rdv2)
      end
    end

    context "when a rdv does not belong to a relevant applicant" do
      it "is filtered" do
        expect(subject.relevant_rdvs).not_to include(irrelevant_rdv)
        expect(subject.relevant_rdvs).not_to include(irrelevant_rdv2)
      end
    end
  end

  describe "#orientation_rdvs" do
    context "when a rdv belongs to a rsa_orientation rdv_context" do
      it "is not filtered" do
        expect(subject.orientation_rdvs).to include(orientation_rdv)
        expect(subject.orientation_rdvs).to include(orientation_rdv2)
      end
    end

    context "when a rdv does not belong to a rsa_orientation rdv_context" do
      it "is filtered" do
        expect(subject.orientation_rdvs).not_to include(orientation_platform_rdv)
        expect(subject.orientation_rdvs).not_to include(accompagnement_rdv)
        expect(subject.relevant_rdvs).not_to include(irrelevant_rdv)
        expect(subject.relevant_rdvs).not_to include(irrelevant_rdv2)
      end
    end
  end

  describe "#relevent_rdv_contexts" do
    context "when a rdv_context belongs to a relevant applicant and has at least one rdv" do
      it "is not filtered" do
        expect(subject.relevant_rdv_contexts).to include(rdv_context_orientation)
        expect(subject.relevant_rdv_contexts).to include(rdv_context_orientation_platform)
      end
    end

    context "when a rdv_context does not belong to a relevant applicant" do
      it "is filtered" do
        expect(subject.relevant_rdv_contexts).not_to include(rdv_context_accompagnement)
      end
    end

    context "when a rdv_context has no rdv" do
      it "is filtered" do
        expect(subject.relevant_rdv_contexts).not_to include(rdv_context_accompagnement)
        expect(subject.relevant_rdv_contexts).not_to include(empty_rdv_context)
      end
    end
  end

  describe "#sent_invitations" do
    context "when an invitation is sent" do
      it "is not filtered" do
        expect(subject.sent_invitations).to include(invitation)
        expect(subject.sent_invitations).to include(invitation2)
        expect(subject.sent_invitations.count).to eq(2)
      end
    end

    context "when an invitation is not sent" do
      it "is filtered" do
        expect(subject.sent_invitations).not_to include(invitation_not_sended)
      end
    end
  end

  describe "#average_time_between_invitation_and_rdv_in_days" do
    it "computes the average time between first invitation and first rdv in days" do
      expect(subject.average_time_between_invitation_and_rdv_in_days.round).to eq(2)
    end
  end

  describe "#average_time_between_invitation_and_rdv_in_days_by_month" do
    it "computes the average time by month between first invitation and first rdv in days" do
      expect(subject.average_time_between_invitation_and_rdv_in_days_by_month).to eq({ "04/2022" => 3, "05/2022" => 1 })
    end
  end

  describe "#average_time_between_rdv_creation_and_start_in_days" do
    it "computes the average time between the creation of the rdvs and the rdvs date in days" do
      expect(subject.average_time_between_rdv_creation_and_start_in_days.round).to eq(3)
    end
  end

  describe "#average_time_between_rdv_creation_and_start_in_days_by_month" do
    it "computes the average time by month between the creation of the rdvs and the rdvs date in days" do
      expect(subject.average_time_between_rdv_creation_and_start_in_days_by_month).to eq(
        { "04/2022" => 1, "05/2022" => 5 }
      )
    end
  end

  describe "#percentage_of_no_show" do
    it "computes the percentage of no show" do
      expect(subject.percentage_of_no_show.round).to eq(50)
    end
  end

  describe "#percentage_of_no_show_by_month" do
    it "computes the percentage of no show by month" do
      expect(subject.percentage_of_no_show_by_month).to eq({ "04/2022" => 0, "05/2022" => 100 })
    end
  end

  describe "#applicants_for_30_days_orientation_scope" do
    let!(:rdv_context_orientation2) { create(:rdv_context, context: "rsa_orientation") }
    let!(:rdv_context_orientation3) { create(:rdv_context, context: "rsa_orientation") }
    let!(:rdv_context_orientation4) { create(:rdv_context, context: "rsa_orientation") }
    let!(:relevant_applicant2) do
      create(:applicant, organisations: [relevant_organisation],
                         rdv_contexts: [rdv_context_orientation2],
                         rights_opening_date: nil,
                         created_at: DateTime.new(2022, 3, 5, 10, 0))
    end
    let!(:irrelevant_applicant) do
      create(:applicant, organisations: [relevant_organisation],
                         rdv_contexts: [rdv_context_orientation3],
                         rights_opening_date: 10.days.ago)
    end
    let!(:irrelevant_applicant2) do
      create(:applicant, organisations: [relevant_organisation],
                         rdv_contexts: [rdv_context_orientation4],
                         rights_opening_date: nil,
                         created_at: 10.days.ago)
    end

    context "when an applicant rights opening date is more than 30 days and has a rsa_orientation rdv_context" do
      it "is not filtered" do
        expect(subject.applicants_for_30_days_orientation_scope).to include(relevant_applicant)
      end
    end

    context "when an applicant rights opening date is nil, creation date is more than 27 days" \
            "and has a rsa_orientation rdv_context" do
      it "is not filtered" do
        expect(subject.applicants_for_30_days_orientation_scope).to include(relevant_applicant2)
      end
    end

    context "when an applicant rights opening date is less than 30 days" do
      it "is is filtered" do
        expect(subject.applicants_for_30_days_orientation_scope).not_to include(irrelevant_applicant)
      end
    end

    context "when an applicant rights opening date is nil and creation date is less than 27 days" do
      it "is filtered" do
        expect(subject.applicants_for_30_days_orientation_scope).not_to include(irrelevant_applicant2)
      end
    end

    context "when an applicant is in time scope and has no rsa_orientation rdv_context" do
      it "is filtered" do
        expect(subject.applicants_for_30_days_orientation_scope).not_to include(relevant_orientation_platform_applicant)
      end
    end
  end

  describe "applicants oriented in time limit" do
    let!(:rdv_context_orientation2) { create(:rdv_context, context: "rsa_orientation") }
    let!(:orientation_rdv2) do
      create(:rdv, rdv_contexts: [rdv_context_orientation2],
                   created_at: DateTime.new(2022, 4, 16, 10, 0),
                   starts_at: DateTime.new(2022, 4, 17, 10, 0),
                   status: "seen")
    end
    let!(:relevant_applicant2) do
      create(:applicant, organisations: [relevant_organisation],
                         rdvs: [orientation_rdv2],
                         rdv_contexts: [rdv_context_orientation2],
                         rights_opening_date: nil,
                         created_at: DateTime.new(2022, 3, 5, 10, 0))
    end

    describe "#percentage_of_applicants_oriented_in_less_than_30_days" do
      it "computes the percentage of applicants oriented in less than 30 days" do
        expect(subject.percentage_of_applicants_oriented_in_less_than_30_days.round).to eq(50)
      end
    end

    describe "#percentage_of_applicants_oriented_in_less_than_30_days_by_month" do
      it "computes the percentage by month of applicants oriented in less than 30 days" do
        expect(subject.percentage_of_applicants_oriented_in_less_than_30_days_by_month).to eq(
          { "03/2022" => 0,
            "04/2022" => 100 }
        )
      end
    end
  end
end

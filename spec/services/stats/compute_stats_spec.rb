describe Stats::ComputeStats, type: :service do
  subject { described_class.call(department_number: department.number) }

  before { travel_to("2022-06-10".to_time) }

  let!(:configuration) { create(:configuration, notify_applicant: false) }
  let!(:configuration_notify) { create(:configuration, notify_applicant: true) }
  let!(:department) { create(:department) }
  let!(:relevant_organisation) { create(:organisation, configurations: [configuration], department: department) }
  let!(:irrelevant_organisation) do # this organisation is irrelevant because she's notifying the applicants
    create(:organisation, configurations: [configuration_notify], department: department)
  end

  # ----------------------------------------- relevant agent for stats -----------------------------------------
  let!(:relevant_agent) { create(:agent, organisations: [relevant_organisation]) }

  # --------------------------------------- relevant applicants for stats --------------------------------------
  let!(:applicant_orientation_from_relevant_organisation) do
    create(:applicant, organisations: [relevant_organisation],
                       department: department,
                       invitations: [invitation],
                       rdvs: [orientation_rdv, accompagnement_rdv],
                       rdv_contexts: [rdv_context_orientation],
                       created_at: "2022-04-01 10:00:00 UTC")
  end
  let!(:applicant_relevant_orientation_platform_from_relevant_organisation) do
    create(:applicant, organisations: [relevant_organisation, irrelevant_organisation],
                       department: department,
                       invitations: [invitation2],
                       rdvs: [orientation_rdv2, accompagnement_rdv2],
                       rdv_contexts: [rdv_context_accompagnement2],
                       created_at: "2022-03-01 10:00:00 UTC")
  end

  # ---------------------------------- rdv_contexts for relevant applicants ------------------------------------
  let!(:rdv_context_orientation) do
    create(:rdv_context, motif_category: "rsa_orientation", created_at: "2022-04-04 10:00:00 UTC")
  end
  let!(:rdv_context_accompagnement) { create(:rdv_context, motif_category: "rsa_accompagnement") }
  let!(:rdv_context_accompagnement2) do
    create(
      :rdv_context, motif_category: "rsa_accompagnement", created_at: "2022-05-07 10:00:00 UTC"
    )
  end

  # ---------------------------------- invitations for relevant applicants -------------------------------------
  let!(:invitation) do
    create(:invitation, sent_at: "2022-04-04 10:00:00 UTC", rdv_context: rdv_context_orientation,
                        department: department)
  end
  let!(:invitation2) do
    create(:invitation, sent_at: "2022-05-07 10:00:00 UTC", rdv_context: rdv_context_accompagnement2,
                        department: department)
  end

  # -------------------------------------- rdvs for relevant applicants ----------------------------------------
  let!(:orientation_rdv) do
    create(:rdv, rdv_contexts: [rdv_context_orientation], organisation: relevant_organisation,
                 created_at: "2022-04-07 10:00:00 UTC",
                 starts_at: "2022-04-08 10:00:00 UTC",
                 created_by: "user",
                 status: "seen")
  end
  let!(:orientation_rdv2) do
    create(:rdv, rdv_contexts: [rdv_context_orientation], organisation: relevant_organisation,
                 created_at: "2022-05-02 10:00:00 UTC",
                 starts_at: "2022-05-07 10:00:00 UTC",
                 status: "noshow")
  end
  let!(:accompagnement_rdv) do
    create(:rdv, rdv_contexts: [rdv_context_accompagnement], organisation: relevant_organisation)
  end
  let!(:accompagnement_rdv2) do
    create(:rdv, rdv_contexts: [rdv_context_accompagnement2], organisation: relevant_organisation,
                 created_at: "2022-05-08 10:00:00 UTC",
                 starts_at: "2022-05-11 10:00:00 UTC")
  end

  # We are creating irrelevant applicants and their related records : they should appear in some general counts, but
  # be filtered when computing precise stats
  # --------------------------- irrelevant applicants (apart for general applicants count) ---------------------
  let!(:applicant_from_irrelevant_organisation) do
    create(:applicant, organisations: [irrelevant_organisation],
                       department: department,
                       rdvs: [irrelevant_rdv],
                       rdv_contexts: [rdv_context_accompagnement],
                       created_at: "2022-04-01 10:00:00 UTC")
  end
  let!(:applicant_deleted) do
    create(:applicant, organisations: [relevant_organisation], department: department,
                       deleted_at: 2.days.ago, rdvs: [irrelevant_rdv2],
                       created_at: "2022-05-01 10:00:00 UTC")
  end
  let!(:applicant_archived) do
    create(:applicant, organisations: [relevant_organisation], department: department, archived_at: 2.days.ago,
                       rdvs: [irrelevant_rdv3], created_at: "2022-05-01 10:00:00 UTC")
  end

  # -------------------------------------------- irrelevant invitation -----------------------------------------
  let!(:invitation_not_sended) { create(:invitation, sent_at: nil, department: department) }

  # ----------------------------- irrelevant rdvs (apart for general rdvs count) -------------------------------
  # They belong to a relevant organisation but to irrelevant applicants (see above)
  let!(:irrelevant_rdv) { create(:rdv, organisation: relevant_organisation) }
  let!(:irrelevant_rdv2) { create(:rdv, organisation: relevant_organisation) }
  let!(:irrelevant_rdv3) { create(:rdv, organisation: relevant_organisation) }

  # ---------------------------------------------- irrelevant agent --------------------------------------------
  let!(:irrelevant_agent) { create(:agent) } # he does not belong to the department
  let!(:irrelevant_agent2) { create(:agent, email: "test@beta.gouv.fr") } # he is a member of the rdv-insertion team

  describe "#call" do
    let!(:data) { subject.data }

    it "is a success" do
      expect(subject.success?).to eq(true)
    end

    it "renders a hash of stats" do
      expect(data).to be_a(Hash)
    end

    it "renders all the stats" do
      expect(data).to include(:department_number)
      expect(data).to include(:applicants_count)
      expect(data).to include(:applicants_count_grouped_by_month)
      expect(data).to include(:rdvs_count)
      expect(data).to include(:rdvs_count_grouped_by_month)
      expect(data).to include(:sent_invitations_count)
      expect(data).to include(:sent_invitations_count_grouped_by_month)
      expect(data).to include(:percentage_of_no_show)
      expect(data).to include(:percentage_of_no_show_grouped_by_month)
      expect(data).to include(:average_time_between_invitation_and_rdv_in_days)
      expect(data).to include(:average_time_between_invitation_and_rdv_in_days_by_month)
      expect(data).to include(:average_time_between_rdv_creation_and_start_in_days)
      expect(data).to include(:average_time_between_rdv_creation_and_start_in_days_by_month)
      expect(data).to include(:rate_of_applicants_with_rdv_seen_in_less_than_30_days)
      expect(data).to include(:rate_of_applicants_with_rdv_seen_in_less_than_30_days_by_month)
      expect(data).to include(:rate_of_autonomous_applicants)
      expect(data).to include(:rate_of_autonomous_applicants_grouped_by_month)
      expect(data).to include(:agents_count)
    end

    describe "#agents_count" do
      it "counts the agents" do
        expect(data[:agents_count]).to eq(1)
      end
    end

    describe "counting applicants" do # applicant counts methods are counting all applicants, even irrelevant ones
      describe "#applicants_count" do
        it "counts the applicants" do
          expect(data[:applicants_count]).to eq(5)
        end
      end

      describe "#applicants_count_grouped_by_month" do
        it "count the applicants month by month" do
          expect(data[:applicants_count_grouped_by_month]).to eq({ "03/2022" => 1, "04/2022" => 2,
                                                                   "05/2022" => 2 })
        end
      end
    end

    describe "counting rdvs" do # rdvs counts methods are counting all rdvs, even irrelevant ones
      describe "#rdvs_count" do
        it "counts the rdvs" do
          expect(data[:rdvs_count]).to eq(7)
        end
      end

      describe "#rdvs_count_grouped_by_month" do
        it "counts the rdvs month by month" do
          expect(data[:rdvs_count_grouped_by_month]).to eq({ "04/2022" => 1, "05/2022" => 2 })
        end
      end
    end

    describe "#sent_invitations_count" do
      it "counts the sent invitations" do
        expect(data[:sent_invitations_count]).to eq(2)
      end
    end

    describe "#sent_invitations_count_grouped_by_month" do
      it "counts the sent invitations month by month" do
        expect(data[:sent_invitations_count_grouped_by_month]).to eq({ "06/2022" => 2 })
      end
    end

    describe "#percentage_of_no_show" do
      it "computes the percentage of no_show for rdvs" do
        expect(data[:percentage_of_no_show]).to eq(50.0)
      end
    end

    describe "#percentage_of_no_show_grouped_by_month" do
      it "computes the percentage of no_show for rdvs" do
        expect(data[:percentage_of_no_show_grouped_by_month]).to eq({ "04/2022" => 0, "05/2022" => 100 })
      end
    end

    describe "#average_time_between_invitation_and_rdv_in_days" do
      it "computes the average time between first invitation and first rdv in days" do
        expect(data[:average_time_between_invitation_and_rdv_in_days]).to eq(2)
      end
    end

    describe "#average_time_between_invitation_and_rdv_in_days_by_month" do
      it "computes the average time by month between first invitation and first rdv in days" do
        expect(data[:average_time_between_invitation_and_rdv_in_days_by_month]).to eq({ "04/2022" => 3,
                                                                                        "05/2022" => 1 })
      end
    end

    describe "#average_time_between_rdv_creation_and_start_in_days" do
      it "computes the average time between the creation of the rdvs and the rdvs date in days" do
        expect(data[:average_time_between_rdv_creation_and_start_in_days]).to eq(3)
      end
    end

    describe "#average_time_between_rdv_creation_and_start_in_days_by_month" do
      it "computes the average time by month between the creation of the rdvs and the rdvs date in days" do
        expect(data[:average_time_between_rdv_creation_and_start_in_days_by_month]).to eq(
          { "04/2022" => 1, "05/2022" => 5 }
        )
      end
    end

    describe "#rate_of_applicants_with_rdv_seen_in_less_than_30_days" do
      it "computes the percentage of applicants with rdv seen in less than 30 days" do
        expect(data[:rate_of_applicants_with_rdv_seen_in_less_than_30_days]).to eq(50)
      end
    end

    describe "#rate_of_applicants_with_rdv_seen_in_less_than_30_days_by_month" do
      it "computes the percentage by month of applicants with rdv seen in less than 30 days" do
        expect(data[:rate_of_applicants_with_rdv_seen_in_less_than_30_days_by_month]).to eq(
          { "03/2022" => 0, "04/2022" => 100 }
        )
      end
    end

    describe "#rate_of_autonomous_applicants" do
      it "computes the percentage of invited applicants with at least on rdv taken in autonomy" do
        expect(data[:rate_of_autonomous_applicants]).to eq(50)
      end
    end

    describe "#rate_of_autonomous_applicants_grouped_by_month" do
      it "computes the percentage by month of invited applicants with at least on rdv taken in autonomy" do
        expect(data[:rate_of_autonomous_applicants_grouped_by_month]).to eq(
          { "03/2022" => 0, "04/2022" => 100 }
        )
      end
    end
  end
end

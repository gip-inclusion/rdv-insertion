describe Stats::ComputeFollowUpSeenRate, type: :service do
  describe "for 45 days" do
    subject { described_class.call(follow_ups: follow_ups, target_delay_days: 45) }

    let(:created_at) { Time.zone.parse("01/03/2022 12:00") }
    let!(:now) { Time.zone.parse("25/04/2022 12:00") }

    let!(:follow_ups) { FollowUp.where(id: [follow_up1, follow_up2, follow_up3, follow_up4]) }

    # First case : created > 1 month ago, has a days_between_follow_up_creation_and_first_seen_rdv present
    # and the delay is less than 45 days
    # => considered as oriented in less than 45 days
    let!(:follow_up1) { create(:follow_up, created_at:) }
    let!(:rdv1) { create(:rdv, created_at:, starts_at: (created_at + 2.days), status: "seen") }
    let!(:participation1) do
      create(:participation, follow_up: follow_up1, rdv: rdv1, created_at:, status: "seen")
    end

    # Second case : created > 1 month ago, has a days_between_follow_up_creation_and_first_seen_rdv present
    # and the delay is more than 45 days
    # => not considered as oriented in less than 45 days
    let!(:follow_up2) { create(:follow_up, created_at:) }
    let!(:rdv2) { create(:rdv, created_at:, starts_at: (created_at + 46.days), status: "seen") }
    let!(:participation2) do
      create(:participation, follow_up: follow_up2, rdv: rdv2, created_at:, status: "seen")
    end

    # Third case : created > 1 month ago, has no days_between_follow_up_creation_and_first_seen_rdv
    # => not considered as oriented in less than 45 days
    let!(:follow_up3) { create(:follow_up, created_at:) }

    # Fourth case : everything okay but created less than 45 days ago
    # not taken into account in the computing
    let!(:follow_up4) { create(:follow_up, created_at: 20.days.ago) }
    let!(:rdv4) { create(:rdv, created_at: 17.days.ago, starts_at: 15.days.ago, status: "seen") }
    let!(:participation4) do
      create(:participation, follow_up: follow_up4, rdv: rdv4, created_at: 17.days.ago, status: "seen")
    end

    before do
      travel_to(now)
    end

    describe "#call" do
      let!(:result) { subject }

      it "is a success" do
        expect(result.success?).to eq(true)
      end

      it "renders a float" do
        expect(result.value).to be_a(Float)
      end

      it "computes the percentage of follow_ups with rdv seen in less than 45 days" do
        expect(result.value).to eq(33.33333333333333)
      end
    end
  end

  describe "for 15 days considering orientation rdv" do
    subject { described_class.call(follow_ups:, target_delay_days: 15, consider_orientation_rdv_as_start: true) }

    let!(:category_orientation) { create(:motif_category, motif_category_type: "rsa_orientation") }
    let!(:category_accompagnement) { create(:motif_category, motif_category_type: "rsa_accompagnement") }

    let(:created_at) { Time.zone.parse("17/03/2022 12:00") }
    let!(:now) { Time.zone.parse("10/04/2022 12:00") }

    let!(:follow_ups) { FollowUp.where(id: [follow_up1, follow_up2, follow_up3, follow_up4, follow_up5, follow_up6]) }

    # First case : created > 15 days ago, has a days_between_follow_up_creation_and_first_seen_rdv present
    # and the delay is less than 30 days
    # => considered as accompanied in less than 15 days
    let!(:follow_up1) { create(:follow_up, created_at:, motif_category: category_accompagnement) }
    let!(:rdv1) { create(:rdv, created_at:, starts_at: (created_at + 2.days), status: "seen") }
    let!(:participation1) do
      create(:participation, follow_up: follow_up1, rdv: rdv1, created_at:, status: "seen")
    end

    # Second case : created > 15 days ago, has a days_between_follow_up_creation_and_first_seen_rdv present
    # and the delay is more than 15 days
    # => not considered as accompanied in less than 15 days
    let!(:follow_up2) { create(:follow_up, created_at:, motif_category: category_accompagnement) }
    let!(:rdv2) { create(:rdv, created_at:, starts_at: (created_at + 16.days), status: "seen") }
    let!(:participation2) do
      create(:participation, follow_up: follow_up2, rdv: rdv2, created_at:, status: "seen")
    end

    # Third case : created > 15 days ago, has no days_between_follow_up_creation_and_first_seen_rdv present
    # => not considered as accompanied in less than 15 days
    let!(:follow_up3) { create(:follow_up, created_at:, motif_category: category_accompagnement) }

    # Fourth case : everything okay but created less than 15 days ago
    # not taken into account in the computing
    let!(:follow_up4) { create(:follow_up, created_at: 10.days.ago, motif_category: category_accompagnement) }
    let!(:rdv4) { create(:rdv, created_at: 7.days.ago, starts_at: 3.days.ago, status: "seen") }
    let!(:participation4) do
      create(:participation, follow_up: follow_up4, rdv: rdv4, created_at: 7.days.ago, status: "seen")
    end

    # Fifth case : created > 15 days ago, has a days_between_follow_up_creation_and_first_seen_rdv present
    # and the delay is more than 15 days BUT has an orientation rdv seen in less than 15 days
    # (days_between_first_orientation_seen_rdv_and_first_seen_rdv < 15)
    # => considered as accompanied in less than 15 days
    let!(:follow_up5) { create(:follow_up, created_at:, motif_category: category_accompagnement) }
    let!(:rdv5) { create(:rdv, created_at:, starts_at: (created_at + 16.days), status: "seen") }
    let!(:participation5) do
      create(:participation, follow_up: follow_up5, rdv: rdv5, created_at:, status: "seen")
    end
    let!(:orientation_follow_up5) { create(:follow_up, created_at:, motif_category: category_orientation) }
    let!(:orientation_rdv5) { create(:rdv, created_at:, starts_at: (created_at + 10.days), status: "seen") }
    let!(:orientation_participation5) do
      create(:participation, follow_up: follow_up5, rdv: orientation_rdv5, created_at:, status: "seen")
    end

    # Sixth case : created > 15 days ago, has a days_between_follow_up_creation_and_first_seen_rdv present
    # and the delay is more than 15 days and has an orientation rdv seen in more than 15 days
    # (days_between_first_orientation_seen_rdv_and_first_seen_rdv > 15)
    # => not considered as accompanied in less than 15 days
    let!(:follow_up6) { create(:follow_up, created_at:, motif_category: category_accompagnement) }
    let!(:rdv6) { create(:rdv, created_at:, starts_at: (created_at + 16.days), status: "seen") }
    let!(:participation6) do
      create(:participation, follow_up: follow_up6, rdv: rdv6, created_at:, status: "seen")
    end
    let!(:orientation_follow_up6) { create(:follow_up, created_at:, motif_category: category_orientation) }
    let!(:orientation_rdv6) { create(:rdv, created_at:, starts_at: (created_at + 16.days), status: "seen") }
    let!(:orientation_participation6) do
      create(:participation, follow_up: follow_up6, rdv: orientation_rdv6, created_at:, status: "seen")
    end

    before do
      travel_to(now)
    end

    describe "#call" do
      let!(:result) { subject }

      it "is a success" do
        expect(result.success?).to eq(true)
      end

      it "renders a float" do
        expect(result.value).to be_a(Float)
      end

      it "computes the percentage of follow_ups with rdv seen in less than 15 days" do
        expect(result.value).to eq(40) # 2 on 5 follow_ups are considered as accompanied in less than 15 days
      end
    end
  end
end

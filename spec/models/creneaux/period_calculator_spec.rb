describe Creneaux::PeriodCalculator do
  subject { described_class.new(motif_category:, organisations: [organisation], from:) }

  let(:from) { Time.zone.parse("2026-06-11 09:00") }
  let!(:organisation) { create(:organisation) }
  let!(:motif_category) { create(:motif_category) }

  context "with several bookable motifs of different delays" do
    before do
      create(:motif, motif_category:, organisation:, bookable_by: "agents_and_prescripteurs_and_invited_users",
                     min_public_booking_delay: 3.days.to_i, max_public_booking_delay: 30.days.to_i)
      create(:motif, motif_category:, organisation:, bookable_by: "agents_and_prescripteurs_and_invited_users",
                     min_public_booking_delay: 1.day.to_i, max_public_booking_delay: 60.days.to_i)
    end

    it "spans from the smallest min delay to the largest max delay" do
      expect(subject.calculate).to eq((from + 1.day)..(from + 60.days))
    end
  end

  context "when a motif is not bookable by invited users" do
    before do
      create(:motif, motif_category:, organisation:, bookable_by: "agents_and_prescripteurs_and_invited_users",
                     min_public_booking_delay: 3.days.to_i, max_public_booking_delay: 30.days.to_i)
      create(:motif, motif_category:, organisation:, bookable_by: "agents",
                     min_public_booking_delay: 1.minute.to_i, max_public_booking_delay: 1.year.to_i)
    end

    it "ignores it" do
      expect(subject.calculate).to eq((from + 3.days)..(from + 30.days))
    end
  end

  context "when a motif is a follow up" do
    before do
      create(:motif, motif_category:, organisation:, bookable_by: "agents_and_prescripteurs_and_invited_users",
                     min_public_booking_delay: 3.days.to_i, max_public_booking_delay: 30.days.to_i)
      create(:motif, motif_category:, organisation:, bookable_by: "agents_and_prescripteurs_and_invited_users",
                     follow_up: true, min_public_booking_delay: 1.minute.to_i, max_public_booking_delay: 1.year.to_i)
    end

    it "ignores it" do
      expect(subject.calculate).to eq((from + 3.days)..(from + 30.days))
    end
  end

  context "when a motif belongs to another organisation" do
    before do
      create(:motif, motif_category:, organisation:, bookable_by: "agents_and_prescripteurs_and_invited_users",
                     min_public_booking_delay: 3.days.to_i, max_public_booking_delay: 30.days.to_i)
      create(:motif, motif_category:, organisation: create(:organisation),
                     bookable_by: "agents_and_prescripteurs_and_invited_users",
                     min_public_booking_delay: 1.minute.to_i, max_public_booking_delay: 1.year.to_i)
    end

    it "ignores it" do
      expect(subject.calculate).to eq((from + 3.days)..(from + 30.days))
    end
  end

  context "when motifs have no booking delays yet (not backfilled)" do
    before do
      create(:motif, motif_category:, organisation:, bookable_by: "agents_and_prescripteurs_and_invited_users",
                     min_public_booking_delay: nil, max_public_booking_delay: nil)
    end

    it "returns nil" do
      expect(subject.calculate).to be_nil
    end
  end

  context "when there is no bookable motif for the category" do
    it "returns nil" do
      expect(subject.calculate).to be_nil
    end
  end
end

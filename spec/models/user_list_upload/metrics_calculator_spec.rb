describe UserListUpload::MetricsCalculator do
  subject { described_class.new(user_list_upload) }

  let!(:user_list_upload) { create(:user_list_upload, user_rows: []) }

  describe "#to_h" do
    context "when there is no processing_log" do
      it "returns a hash with nil values for time metrics and calculates rates from user_rows" do
        create(:user_row, user_list_upload:, selected_for_user_save: true)

        expect(subject.time_between_user_saves_triggered_and_user_saves_ended).to be_nil
        expect(subject.time_between_user_saves_triggered_and_user_saves_started).to be_nil
        expect(subject.time_between_user_saves_started_and_user_saves_ended).to be_nil
        expect(subject.time_between_user_saves_started_and_user_saves_ended_per_user_row).to be_nil
        expect(subject.time_between_invitations_triggered_and_invitations_started).to be_nil
        expect(subject.time_between_invitations_triggered_and_invitations_ended).to be_nil
        expect(subject.time_between_invitations_started_and_invitations_ended).to be_nil
        expect(subject.time_between_invitations_started_and_invitations_ended_per_user_row).to be_nil
      end
    end

    context "when there is a complete processing_log with user_rows" do
      let(:base_time) { Time.zone.parse("2024-01-01 10:00:00") }

      let!(:processing_log) do
        create(
          :user_list_upload_processing_log,
          user_list_upload:,
          user_saves_triggered_at: base_time,
          user_saves_started_at: base_time + 5.seconds,
          user_saves_ended_at: base_time + 25.seconds,
          invitations_triggered_at: base_time + 30.seconds,
          invitations_started_at: base_time + 35.seconds,
          invitations_ended_at: base_time + 55.seconds
        )
      end

      let!(:user_row_1) do
        create(:user_row, user_list_upload:, selected_for_user_save: true, selected_for_invitation: true)
      end

      let!(:user_row_2) do
        create(:user_row, user_list_upload:, selected_for_user_save: true, selected_for_invitation: false)
      end

      let!(:user_row_3) do
        create(:user_row, :not_selected_for_user_save, user_list_upload:)
      end

      let!(:successful_user_save_1) do
        create(:user_save_attempt, user_row: user_row_1, success: true)
      end

      let!(:failed_user_save) do
        create(:user_save_attempt, user_row: user_row_2, success: false)
      end

      let!(:successful_invitation_1) do
        create(:invitation_attempt, user_row: user_row_1, success: true)
      end

      let!(:successful_invitation_2) do
        create(:invitation_attempt, user_row: user_row_1, success: true, format: "sms")
      end

      it "returns correct time differences in seconds" do
        expect(subject.time_between_user_saves_triggered_and_user_saves_ended).to eq(25.0)
        expect(subject.time_between_user_saves_triggered_and_user_saves_started).to eq(5.0)
        expect(subject.time_between_user_saves_started_and_user_saves_ended).to eq(20.0)
        expect(subject.time_between_user_saves_started_and_user_saves_ended_per_user_row).to eq(10.0)
        expect(subject.time_between_invitations_triggered_and_invitations_started).to eq(5.0)
        expect(subject.time_between_invitations_triggered_and_invitations_ended).to eq(25.0)
        expect(subject.time_between_invitations_started_and_invitations_ended).to eq(20.0)
        expect(subject.time_between_invitations_started_and_invitations_ended_per_user_row).to eq(20.0)
      end

      it "returns correct percentage rates" do
        expect(subject.rate_of_selected_rows_for_user_save).to eq(66.67)
        expect(subject.rate_of_selected_rows_for_invitation).to eq(33.33)
        expect(subject.rate_of_user_saves_succeeded).to eq(50.0)
        expect(subject.rate_of_invitations_succeeded).to eq(100.0)
        expect(subject.rate_of_saved_users).to eq(33.33)
        expect(subject.rate_of_invited_users).to eq(33.33)
      end
    end

    context "when processing_log has partial timestamps" do
      let(:base_time) { Time.zone.parse("2024-01-01 10:00:00") }

      let!(:processing_log) do
        create(
          :user_list_upload_processing_log,
          user_list_upload:,
          user_saves_triggered_at: base_time,
          user_saves_started_at: base_time + 10.seconds,
          user_saves_ended_at: nil,
          invitations_triggered_at: nil,
          invitations_started_at: nil,
          invitations_ended_at: nil
        )
      end

      it "returns nil for metrics that cannot be calculated" do
        expect(subject.time_between_user_saves_triggered_and_user_saves_ended).to be_nil
        expect(subject.time_between_user_saves_triggered_and_user_saves_started).to eq(10.0)
        expect(subject.time_between_user_saves_started_and_user_saves_ended).to be_nil
        expect(subject.time_between_invitations_triggered_and_invitations_started).to be_nil
      end
    end

    context "when there are no user_rows" do
      let!(:processing_log) do
        create(:user_list_upload_processing_log, user_list_upload:)
      end

      it "returns nil for percentage metrics that would divide by zero" do
        expect(subject.rate_of_selected_rows_for_user_save).to be_nil
        expect(subject.rate_of_selected_rows_for_invitation).to be_nil
        expect(subject.rate_of_saved_users).to be_nil
        expect(subject.rate_of_invited_users).to be_nil
      end
    end

    context "when there are no attempts" do
      let!(:processing_log) do
        create(:user_list_upload_processing_log, user_list_upload:)
      end

      let!(:user_row) do
        create(:user_row, user_list_upload:, selected_for_user_save: true)
      end

      it "returns nil for success rate metrics that would divide by zero" do
        expect(subject.rate_of_user_saves_succeeded).to be_nil
        expect(subject.rate_of_invitations_succeeded).to be_nil
      end
    end
  end
end

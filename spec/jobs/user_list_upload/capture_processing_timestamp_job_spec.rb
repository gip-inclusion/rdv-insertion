describe UserListUpload::CaptureProcessingTimestampJob do
  subject { described_class.new.perform(user_list_upload.id, timestamp_name, value) }

  let!(:user_list_upload) { create(:user_list_upload) }
  let!(:timestamp_name) { "user_saves_triggered_at" }
  let!(:value) { Time.zone.parse("2025-01-01 12:00:01.242567") }

  describe "#perform" do
    context "when the processing log does not exist" do
      it "creates a processing log" do
        expect { subject }.to change(UserListUpload::ProcessingLog, :count).by(1)
      end

      it "sets the timestamp on the processing log" do
        subject
        expect(user_list_upload.processing_log.send(timestamp_name)).to eq(value)
      end
    end

    context "when the processing log already exists" do
      let!(:processing_log) { create(:user_list_upload_processing_log, user_list_upload:) }

      it "updates the processing log" do
        subject
        expect(processing_log.reload.send(timestamp_name)).to eq(value)
      end

      it "does not create a new processing log" do
        expect { subject }.not_to change(UserListUpload::ProcessingLog, :count)
      end
    end
  end
end

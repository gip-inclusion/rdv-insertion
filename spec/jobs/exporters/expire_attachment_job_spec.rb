describe Exporters::ExpireAttachmentJob do
  subject do
    described_class.new.perform(csv_export.id)
  end

  let(:csv_export) { create(:csv_export) }

  it "expires the attachment" do
    expect { subject }.to change { csv_export.reload.file.attached? }.from(true).to(false)
  end
end

describe HasAttachedImage, type: :concern do
  let(:base_class) do
    Class.new(ApplicationRecord) do
      self.table_name = "organisations"
      include HasAttachedImage
    end
  end

  describe "service selection" do
    context "without publicly_accessible option" do
      it "uses default service" do
        expect(base_class).to receive(:has_one_attached).with(:logo, service: nil)
        base_class.has_attached_image :logo
      end
    end

    context "with publicly_accessible: true in production" do
      before { allow(Rails).to receive_message_chain(:env, :production?).and_return(true) }

      it "uses public service" do
        expect(base_class).to receive(:has_one_attached).with(:logo, service: :scaleway_public)
        base_class.has_attached_image :logo, publicly_accessible: true
      end
    end
  end
end

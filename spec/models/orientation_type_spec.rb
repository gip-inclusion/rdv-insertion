describe OrientationType do
  let!(:orientation_type_social) do
    create(:orientation_type, name: "Sociale", casf_category: "social", department: nil)
  end
  let!(:orientation_type_pro) do
    create(:orientation_type, name: "Professionnelle", casf_category: "pro", department: nil)
  end
  let!(:orientation_type_socio_pro) do
    create(:orientation_type, name: "Socio-professionnelle", casf_category: "socio_pro", department: nil)
  end

  describe "deletion" do
    context "orientation is custom" do
      let(:department) { create(:department) }
      let!(:custom_pro_orientation_type) do
        create(:orientation_type, name: "Custom Pro", casf_category: "pro", department:)
      end

      it "reassigns orientations" do
        orientation = create(:orientation, orientation_type: custom_pro_orientation_type)
        custom_pro_orientation_type.destroy
        orientation.reload

        expect(orientation.orientation_type).to eq(orientation_type_pro)
      end
    end

    context "orientation is default" do
      it "prevents deletion" do
        expect { orientation_type_pro.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
      end
    end
  end

  describe "scopes" do
    describe ".for_department" do
      let(:department) { create(:department) }

      context "department has custom orientation types" do
        let!(:custom_pro_orientation_type) do
          create(:orientation_type, name: "Custom Pro", casf_category: "pro", department:)
        end

        let!(:custom_pro_orientation_type2) do
          create(:orientation_type, name: "Custom Pro 2", casf_category: "pro", department:)
        end

        it "returns the department scoped orientation types and default orientation types" do
          expect(described_class.for_department(custom_pro_orientation_type.department).order(name: :asc)).to eq(
            [custom_pro_orientation_type, custom_pro_orientation_type2, orientation_type_social,
             orientation_type_socio_pro]
          )
        end
      end

      context "department has no custom orientation types" do
        it "returns only the default orientation types" do
          expect(described_class.for_department(department)).to eq(
            [orientation_type_social, orientation_type_pro, orientation_type_socio_pro]
          )
        end
      end
    end
  end
end

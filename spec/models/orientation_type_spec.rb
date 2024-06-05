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

  describe "scopes" do
    describe ".for_department" do
      let(:department) { create(:department) }

      context "department has custom orientation types" do
        let!(:custom_pro_orientation_type) do
          create(:orientation_type, casf_category: "pro", department:)
        end

        it "returns the department scoped orientation types and default orientation types" do
          expect(described_class.for_department(custom_pro_orientation_type.department)).to eq(
            [custom_pro_orientation_type, orientation_type_social, orientation_type_socio_pro]
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

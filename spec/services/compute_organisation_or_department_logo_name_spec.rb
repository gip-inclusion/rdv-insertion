describe ComputeOrganisationOrDepartmentLogoName, type: :service do
  subject do
    described_class.call(department_name: department_name, organisation_name: organisation_name)
  end

  let!(:department_name) { "seine-saint-denis" }
  let!(:organisation_name) { "pie-pantin" }

  describe "#call" do
    it("is a success") { is_a_success }

    it "returns a logo name" do
      expect(subject.logo_name).to eq("pie-pantin")
    end

    context "if there is no logo with the organisation name" do
      let!(:organisation_name) { "pie-paris" }

      it "returns the department name" do
        expect(subject.logo_name).to eq("seine-saint-denis")
      end
    end

    context "if no organisation name is passed" do
      let!(:organisation_name) { nil }

      it "returns the department name" do
        expect(subject.logo_name).to eq("seine-saint-denis")
      end
    end
  end
end

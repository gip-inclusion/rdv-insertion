class ComputeOrganisationOrDepartmentLogoName < BaseService
  def initialize(department_name:, organisation_name: nil)
    @department_name = department_name
    @organisation_name = organisation_name
  end

  def call
    result.logo_name = logo_name
  end

  private

  def logo_name
    @logo_name ||= if @organisation_name.present? && ComputeLogoFormat.call(logo_name: @organisation_name).success?
                     @organisation_name
                   else
                     @department_name
                   end
  end
end

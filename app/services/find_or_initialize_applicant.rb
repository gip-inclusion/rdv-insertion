class FindOrInitializeApplicant < BaseService
  def initialize(applicant_params:, organisation:)
    @applicant_params = applicant_params
    @organisation = organisation
  end

  def call
    result.applicant = find_or_initialize_applicant
  end

  private

  def find_or_initialize_applicant
    find_applicant_by_department_internal_id ||
      find_applicant_by_role_and_affiliation_number ||
      Applicant.new
  end

  def find_applicant_by_department_internal_id
    return if @applicant_params[:department_internal_id].blank?

    Applicant.find_by(department_internal_id: @applicant_params[:department_internal_id])
  end

  def find_applicant_by_role_and_affiliation_number
    return if @applicant_params[:role].blank? || @applicant_params[:affiliation_number].blank?

    Applicant.find_by(
      affiliation_number: @applicant_params[:affiliation_number],
      role: @applicant_params[:role]
    )
  end
end

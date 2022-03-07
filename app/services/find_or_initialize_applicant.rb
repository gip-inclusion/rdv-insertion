class FindOrInitializeApplicant < BaseService
  def initialize(department_internal_id:, role:, affiliation_number:)
    @department_internal_id = department_internal_id
    @role = role
    @affiliation_number = affiliation_number
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
    return if @department_internal_id.blank?

    Applicant.find_by(department_internal_id: @department_internal_id)
  end

  def find_applicant_by_role_and_affiliation_number
    return if @role.blank? || @affiliation_number.blank?

    Applicant.find_by(
      affiliation_number: @affiliation_number,
      role: @role
    )
  end
end

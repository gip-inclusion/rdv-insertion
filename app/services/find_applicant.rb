class FindApplicant < BaseService
  def initialize(applicant_params:, organisation:)
    @applicant_params = applicant_params
    @organisation = organisation
  end

  def call
    @applicant = find_applicant
    check_if_applicant_exists_and_belongs_to_organisation
    update_applicant_and_add_to_organisation
    result.applicant = @applicant
  end

  private

  def find_applicant
    @find_applicant ||=
      find_applicant_by_department_internal_id ||
      find_applicant_by_role_and_affiliation_number
  end

  def find_applicant_by_department_internal_id
    return if @applicant_params[:department_internal_id].blank?

    @find_applicant_by_department_internal_id ||= \
      Applicant.find_by(department_internal_id: @applicant_params[:department_internal_id])
  end

  def find_applicant_by_role_and_affiliation_number
    return if @applicant_params[:role].blank? || @applicant_params[:affiliation_number].blank?

    @find_applicant_by_role_and_affiliation_number ||= \
      Applicant.find_by(
        affiliation_number: @applicant_params[:affiliation_number],
        role: @applicant_params[:role]
      )
  end

  def check_if_applicant_exists_and_belongs_to_organisation
    fail! if @applicant.nil? || @applicant.organisations.include?(@organisation)
  end

  def update_applicant_and_add_to_organisation
    @applicant.assign_attributes(
      organisations: (@applicant.organisations.to_a + [@organisation]).uniq,
      **@applicant_params.compact_blank!
    )
  end
end

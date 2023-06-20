module SetOrganisationAndDepartmentConcern
  include ActiveSupport::Concern

  private

  def set_organisation
    @organisation =
      if department_level?
        set_organisation_at_department_level
      else
        policy_scope(Organisation).find(params[:organisation_id])
      end
  end

  def set_organisation_at_department_level
    return set_organisation_through_applicant_form if params[:action] == "create" && controller_name == "applicants"
    return if @applicant.nil? # no need to set an organisation if we are not in an applicant-level page

    @organisation = policy_scope(Organisation)
                    .find_by(id: @applicant.organisation_ids, department_id: params[:department_id])
  end

  def set_organisation_through_applicant_form
    # for now we allow only one organisation through creation
    @organisation = Organisation.find_by(
      id: params[:applicant][:organisation_ids], department_id: params[:department_id]
    )
  end

  def set_organisations
    @organisations = policy_scope(Organisation).where(department: @department)
  end

  def set_department
    @department =
      if department_level?
        policy_scope(Department).find(params[:department_id])
      else
        @organisation.department
      end
  end
end

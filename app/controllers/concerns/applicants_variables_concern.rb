module ApplicantsVariablesConcern
  def set_organisation
    @organisation = \
      if department_level?
        set_organisation_at_department_level
      else
        policy_scope(Organisation).includes(:applicants, :configurations).find(params[:organisation_id])
      end
  end

  def set_organisation_at_department_level
    return set_organisation_through_form if params[:action] == "create"
    return if @applicant.nil?

    @organisation = policy_scope(Organisation)
                    .find_by(id: @applicant.organisation_ids, department_id: params[:department_id])
  end

  def set_organisation_through_form
    # for now we allow only one organisation through creation
    @organisation = Organisation.find_by(
      id: params[:applicant][:organisation_ids], department_id: params[:department_id]
    )
  end

  def set_department
    @department = \
      if department_level?
        policy_scope(Department).includes(:organisations, :applicants).find(params[:department_id])
      else
        @organisation.department
      end
  end

  def set_all_configurations
    @all_configurations = \
      if department_level?
        (policy_scope(::Configuration) & @department.configurations).uniq(&:motif_category)
      else
        @organisation.configurations
      end
  end


end

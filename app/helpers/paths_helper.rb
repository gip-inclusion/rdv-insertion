module PathsHelper
  def department_level?
    params[:department_id].present?
  end

  def navigation_level
    department_level? ? "department" : "organisation"
  end

  def compute_applicants_path(organisation, department, **params)
    if department_level?
      department_applicants_path(department, **params.compact_blank)
    else
      organisation_applicants_path(organisation, **params.compact_blank)
    end
  end

  def compute_rdv_contexts_list_path(organisation, department, motif_category, **params)
    if department_level?
      department_motif_category_rdv_contexts_path(department, motif_category, **params.compact_blank)
    else
      organisation_motif_category_rdv_contexts_path(organisation, motif_category, **params.compact_blank)
    end
  end

  def compute_archives_path(organisation, department, **params)
    if department_level?
      department_archives_path(department, **params.compact_blank)
    else
      organisation_archives_path(organisation, **params.compact_blank)
    end
  end

  def compute_edit_applicant_path(applicant, organisation, department)
    return edit_department_applicant_path(department, applicant) if department_level?

    edit_organisation_applicant_path(organisation, applicant)
  end

  def compute_applicant_path(applicant, organisation, department)
    return department_applicant_path(department, applicant) if department_level?

    organisation_applicant_path(organisation, applicant)
  end

  def compute_new_applicant_path(organisation, department)
    return new_department_applicant_path(department) if department_level?

    new_organisation_applicant_path(organisation)
  end

  def compute_rdv_contexts_path(organisation, department)
    return rdv_contexts_path(department_id: department.id) if department_level?

    rdv_contexts_path(organisation_id: organisation.id)
  end
end

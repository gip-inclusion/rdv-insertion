module Applicants::Sortable
  def order_applicants
    return if params[:search_query].present?

    if archived_scope?
      archived_order
    elsif @current_motif_category
      motif_category_order
    else
      all_applicants_order
    end
  end

  def archived_order
    @applicants.order("archives.created_at desc")
  end

  def motif_category_order
    @applicants = @applicants
                  .select("DISTINCT(applicants.id), applicants.*, rdv_contexts.created_at")
                  .order("rdv_contexts.created_at desc")
  end

  def all_applicants_order
    if department_level?
      associated_applicants_organisations = ApplicantsOrganisation
                                            .where(organisations: @organisations)
                                            .order(created_at: :desc)
                                            .uniq(&:applicant_id)
                                            .map(&:id)

      applicants_affected_most_recently_to_an_organisation = {
        applicants_organisations: {
          id: associated_applicants_organisations
        }
      }
    end

    @applicants = @applicants.includes(:applicants_organisations, :archives)
                             .select("
                                DISTINCT(applicants.id),
                                applicants.*,
                                applicants_organisations.created_at as affected_at
                              ")
                             .active
                             .where(applicants_affected_most_recently_to_an_organisation || {})
                             .order("affected_at DESC NULLS LAST, applicants.id DESC")
  end
end

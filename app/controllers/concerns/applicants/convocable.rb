module Applicants::Convocable
  private

  # used on applicants#index
  def set_convocation_motifs_by_applicant
    return if archived_scope?
    return unless @current_configuration&.convene_applicant?

    convocation_motifs = Motif.includes(:organisation).active.where(
      organisation_id: department_level? ? @organisations.ids : @organisation.id,
      motif_category: @current_motif_category
    ).select(&:convocation?)

    @convocation_motifs_by_applicant = @applicants.index_with do |applicant|
      if department_level?
        convocation_motifs.find { |motif| motif.organisation_id.in?(applicant.organisation_ids) }
      else
        convocation_motifs.first
      end
    end
  end

  # used on applicants#show
  def set_convocation_motifs_by_rdv_context
    return if archived_scope?
    return if @all_configurations.none?(&:convene_applicant?)

    convocation_motifs = Motif.includes(:organisation).active.where(
      organisation_id: @applicant_organisations.ids, motif_category: @all_configurations.map(&:motif_category)
    ).select(&:convocation?)

    @convocation_motifs_by_rdv_context = @rdv_contexts.index_with do |rdv_context|
      organisation_ids = department_level? ? @applicant_organisations.ids : [@organisation.id]
      convocation_motifs.find do |motif|
        motif.motif_category_id == rdv_context.motif_category_id &&
          motif.organisation_id.in?(organisation_ids)
      end
    end
  end
end

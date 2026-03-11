module MotifsHelper
  def rdv_solidarites_motifs_url(organisation)
    "#{ENV['RDV_SOLIDARITES_URL']}/admin/organisations/#{organisation.rdv_solidarites_organisation_id}/motifs"
  end

  def rdv_solidarites_new_motif_url(organisation)
    "#{ENV['RDV_SOLIDARITES_URL']}/admin/organisations/#{organisation.rdv_solidarites_organisation_id}/motifs/new"
  end

  def rdv_solidarites_edit_motif_url(organisation, motif)
    "#{ENV['RDV_SOLIDARITES_URL']}/admin/organisations/#{organisation.rdv_solidarites_organisation_id}/" \
      "motifs/#{motif.rdv_solidarites_motif_id}/edit"
  end
end

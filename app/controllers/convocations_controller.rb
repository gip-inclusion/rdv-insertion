class ConvocationsController < ApplicationController
  before_action :set_organisations, :set_motif_category, :set_applicant

  def new
    @convocation_links_by_type = {
      individuel: individuel_convocation_motif_link,
      collectif: collectif_convocation_link
    }
    @all_links = @convocation_links_by_type.values.compact

    return redirect_to @all_links.first if @all_links.length == 1
  end

  private

  def set_organisations
    @organisations = policy_scope(Organisation).where(id: params[:organisation_ids])
  end

  def set_motif_category
    @motif_category = MotifCategory.find(params[:motif_category_id])
  end

  def set_applicant
    @applicant = policy_scope(Applicant).find(params[:applicant_id])
  end

  def individuel_convocation_motif
    # first motif mentionning "convocation" in that category
    @individuel_convocation_motif ||=
      Motif.active.individuel.where(organisations: @organisations, motif_category: @motif_category).find(&:convocation?)
  end

  def individuel_convocation_motif_link
    individuel_convocation_motif&.link_to_take_rdv_for(@applicant.rdv_solidarites_user_id)
  end

  def collectif_available_rdv
    # any collective rdv on that category
    @collectif_available_rdv ||=
      Rdv.collectif_and_available_for_reservation
         .where(motifs: { motif_category: @motif_category })
         .where(organisations: @organisations)
         .first
  end

  def collectif_convocation_link
    collectif_available_rdv&.add_user_url(@applicant.rdv_solidarites_user_id)
  end
end

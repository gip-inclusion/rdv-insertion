module RdvContexts
  class Create < BaseService
    def initialize(rdv_context:, user:)
      @rdv_context = rdv_context
      @user = user
    end

    def call
      check_if_user_has_an_organisation_for_this_motif_category!
      save_record!(@rdv_context)
      result.rdv_context = @rdv_context
    end

    def check_if_user_has_an_organisation_for_this_motif_category!
      return if @user.organisations_motif_category_ids.include?(@rdv_context.motif_category_id)

      fail!("L'utilisateur n'appartient à aucune organisation gérant cette catégorie de motifs")
    end
  end
end

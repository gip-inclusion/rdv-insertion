module RdvContexts
  class Create < BaseService
    def initialize(rdv_context:, user:)
      @rdv_context = rdv_context
      @user = user
    end

    def call
      RdvContext.transaction do
        check_if_user_has_an_appropriate_organisation!
        save_record!(@rdv_context)
      end
    end

    def check_if_user_has_an_appropriate_organisation!
      return if @user.organisations_motif_category_ids.include?(@rdv_context.motif_category_id)

      fail!("L'utilisateur n'appartient à aucune organisation gérant cette catégorie de motifs")
    end
  end
end

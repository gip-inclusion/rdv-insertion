module RdvContexts
  class FindOrCreate < BaseService
    include Pundit

    def initialize(user:, motif_category:)
      @user = user
      @motif_category = motif_category
    end

    def call
      RdvContext.with_advisory_lock "setting_rdv_context_for_user_#{@user.id}" do
        find_or_create_rdv_context!
        result.rdv_context = @rdv_context
      end
    end

    private

    def find_or_create_rdv_context!
      return if rdv_context_already_exists?

      create_rdv_context!
    end

    def create_rdv_context!
      RdvContext.transaction do
        @rdv_context = RdvContext.new(user: @user, motif_category: @motif_category)
        check_if_user_has_an_organisation_for_this_motif_cateogry!
        authorize @rdv_context, :create?
        save_record!(@rdv_context)
      end
    end

    def rdv_context_already_exists?
      @rdv_context = RdvContext.find_by(user: @user, motif_category: @motif_category)
    end

    def check_if_user_has_an_organisation_for_this_motif_cateogry!
      return if @user.organisations_motif_category_ids.include?(@rdv_context.motif_category_id)

      fail!("L'utilisateur n'appartient à aucune organisation gérant cette catégorie de motifs")
    end

    def pundit_user
      Current.agent
    end
  end
end

module RdvContexts
  class CleanUnusedRdvContexts < BaseService
    # This service is used to clean the rdv_contexts of a user
    # when he is no longer member of an organisation that handle this motif_category
    def initialize(user:)
      @user = user
    end

    def call
      @user.rdv_contexts.each do |rdv_context|
        next if @user.organisations.any? do |organisation|
          organisation.motif_categories.include?(rdv_context.motif_category)
        end
        next if rdv_context.status != "not_invited"

        rdv_context.destroy!
      end
    end
  end
end

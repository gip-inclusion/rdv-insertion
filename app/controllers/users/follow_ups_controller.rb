module Users
  class FollowUpsController < ApplicationController
    include Users::EnsurePresenceInStructure

    before_action :set_user, :ensure_user_presence_in_structure, :set_department, :set_organisation,
                  :set_user_department_organisations, :set_all_configurations, :set_user_tags,
                  :set_back_to_users_list_url, only: [:index]

    include BackToListConcern
    include Users::Taggable

    def index
      @follow_ups =
        FollowUp.preload(
          :invitations, :motif_category, participations: [:notifications, { rdv: [:motif, :organisation] }]
        ).where(
          user: @user, motif_category: @all_configurations.map(&:motif_category)
        ).sort_by do |follow_up|
          @all_configurations.find_index do |c|
            c.motif_category_id == follow_up.motif_category_id
          end
        end
    end

    private

    def set_user
      @user = policy_scope(User).where(current_organisations_filter).preload(
        organisations: [:department, :motif_categories], follow_ups: :participations,
        tags: :tag_organisations, invitations: :follow_up
      ).find_by(id: params[:user_id])
    end

    def set_department
      @department = policy_scope(Department).preload(organisations: [:motif_categories, :motifs, :lieux])
                                            .find(current_department_id)
    end

    def set_organisation
      return if department_level?

      @organisation = policy_scope(Organisation).preload(:department, :motif_categories).find(current_organisation_id)
    end

    def set_all_configurations
      @all_configurations =
        policy_scope(CategoryConfiguration)
        .joins(:organisation)
        .where(current_organisation_filter)
        .where({ organisation: @user.department_organisations(@department).map(&:id) })
        .preload(:motif_category)
        .uniq(&:motif_category_id)

      @all_configurations =
        department_level? ? @all_configurations.sort_by(&:department_position) : @all_configurations.sort_by(&:position)
    end

    def set_user_department_organisations
      @user_department_organisations =
        policy_scope(Organisation).where(id: @user.organisation_ids, department: @department)
    end
  end
end

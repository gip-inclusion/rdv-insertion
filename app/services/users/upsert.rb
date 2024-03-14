module Users
  class Upsert < BaseService
    def initialize(user_attributes:, organisation:)
      @user_attributes = user_attributes
      @organisation = organisation
    end

    def call
      @user = find_or_initialize_user.user
      result.user = @user
      @user.assign_attributes(**@user_attributes.compact_blank)
      save_user!
    end

    private

    def find_or_initialize_user
      @find_or_initialize_user ||= call_service!(
        Users::FindOrInitialize,
        attributes: @user_attributes,
        department_id: @organisation.department_id
      )
    end

    def save_user!
      call_service!(
        Users::Save,
        user: @user,
        organisation: @organisation
      )
    end
  end
end


organisation = Organisation.find(190)
organisations = Organisation.find([190, 191, 192, 236])
rsa_orientation = MotifCategory.find_by(short_name: "rsa_orientation")
rsa_accompagnement = MotifCategory.find_by(short_name: "rsa_accompagnement")

organisations.each do |organisation|
  users_with_only_one_organisation = organisation.users.group(:id).having('COUNT(organisation_id) = 1').pluck(:id)

  rdv_contexts = RdvContext.where(user_id: users_with_only_one_organisation, motif_category: rsa_orientation)
  rdv_contexts.each do |rdv_context|
    rdv_context.motif_category = rsa_accompagnement
    rdv_context.save!
  end
end
module Users
  class ValidateDepartmentUniqueness < BaseService
    def initialize(user:, organisation: nil)
      @user = user
      @organisation = organisation
    end

    def call
      validate_department_uniqueness_of(:nir, @user.nir)
      validate_department_uniqueness_of(:france_travail_id, @user.france_travail_id)
    end

    private

    def validate_department_uniqueness_of(attribute, value)
      return if value.blank? || relevant_department_ids.empty?

      conflicting_users = conflicting_users_by(attribute, value)
      return if conflicting_users.none?

      fail!(
        "Un usager avec le même #{User.human_attribute_name(attribute)} " \
        "se trouve au sein du département: #{conflicting_users.pluck(:id).uniq}"
      )
    end

    def conflicting_users_by(attribute, value)
      User.active.where(attribute => value)
          .joins(:organisations)
          .where(organisations: { department_id: relevant_department_ids })
          .where.not(id: @user.id)
    end

    def relevant_department_ids
      @relevant_department_ids ||= begin
        ids = @user.organisations.map(&:department_id).compact
        ids << @organisation.department_id if @organisation
        ids.uniq
      end
    end
  end
end

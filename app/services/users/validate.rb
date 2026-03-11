module Users
  class Validate < BaseService
    def initialize(user:, organisation: nil)
      @user = user
      @organisation = organisation
    end

    def call
      validate_nir_uniqueness_in_department
      validate_france_travail_id_uniqueness_in_department
    end

    private

    def validate_nir_uniqueness_in_department
      return if @user.nir.blank? || relevant_department_ids.empty?

      conflicting = conflicting_users_by(:nir, @user.nir)
      return if conflicting.none?

      fail!("Un usager avec le même NIR se trouve au sein du département: #{conflicting.pluck(:id)}")
    end

    def validate_france_travail_id_uniqueness_in_department
      return if @user.france_travail_id.blank? || relevant_department_ids.empty?

      conflicting = conflicting_users_by(:france_travail_id, @user.france_travail_id)
      return if conflicting.none?

      fail!("Un usager avec le même ID France Travail se trouve au sein du département: #{conflicting.pluck(:id)}")
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
        ids << @organisation.department_id if @organisation.present?
        ids.uniq
      end
    end
  end
end

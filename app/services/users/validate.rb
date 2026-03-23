module Users
  class Validate < BaseService
    def initialize(user:, organisation: nil)
      @user = user
      @organisation = organisation
    end

    def call
      validate_department_uniqueness_of(:nir, @user.nir)
      validate_department_uniqueness_of(:france_travail_id, @user.france_travail_id)
      validate_identifier_not_removed if @user.persisted?
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

    def validate_identifier_not_removed
      return unless removing_all_identifiers?

      fail!(
        "Impossible de retirer tous les identifiants (NIR, email, numéro de tel, ID interne, numéro CAF/rôle) " \
        "d'un usager"
      )
    end

    def removing_all_identifiers?
      !identifiable? && previously_identifiable?
    end

    def previously_identifiable?
      %i[nir department_internal_id email phone_number].any? { |attr| @user.attribute_in_database(attr).present? } ||
        (@user.attribute_in_database(:affiliation_number).present? && @user.attribute_in_database(:role).present?)
    end

    def identifiable?
      @user.nir? || @user.department_internal_id? || @user.email? || @user.phone_number? ||
        (@user.affiliation_number? && @user.role?)
    end
  end
end

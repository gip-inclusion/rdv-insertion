module Api
  module V1
    module ParamsValidationConcern
      extend ActiveSupport::Concern

      private

      def validate_users_params
        @params_validation_errors = []

        validate_users_length
        validate_users_attributes

        return if @params_validation_errors.empty?

        render json: { success: false, errors: @params_validation_errors }, status: :unprocessable_entity
      end

      def validate_user_params
        @params_validation_errors = []
        validate_user_attributes(user_attributes.except(:referents_to_add))
        Array(user_attributes[:referents_to_add]).each { validate_referent_exists(_1[:email]) }

        return if @params_validation_errors.empty?

        render json: { success: false, errors: @params_validation_errors }, status: :unprocessable_entity
      end

      def validate_users_length
        return if users_attributes.length <= 25

        @params_validation_errors << {
          error_details: "Les usagers doivent être envoyés par lots de 25 maximum"
        }
      end

      def validate_users_attributes
        users_attributes.each_with_index do |user_attributes, idx|
          validate_user_attributes(user_attributes.except(:invitation, :referents_to_add), idx)
          Array(user_attributes[:referents_to_add]).each { validate_referent_exists(_1[:email], idx) }
        end
      end

      def validate_referent_exists(referent_email, idx = nil)
        return if @organisation.agents.find_by(email: referent_email)

        @params_validation_errors << {
          error_details: "Assignation du référent impossible car aucun agent n'a été retrouvé " \
                         "avec l'adresse #{referent_email} au sein de l'organisation #{@organisation.name}. "
        }.merge(idx.present? ? { index: idx } : {})
      end

      def validate_user_attributes(user_attributes, idx = nil)
        return if validate_user_role(user_attributes, idx)
        return if validate_user_title(user_attributes, idx)

        validate_user_model(user_attributes, idx)
      end

      def validate_user_role(user_attributes, idx = nil)
        return false unless user_attributes[:role].present? && !User.roles.key?(user_attributes[:role])

        @params_validation_errors << {
          error_details: I18n.t("activerecord.errors.models.user.attributes.role.inclusion",
                                valid_values: User.roles.keys.join(", ")),
          first_name: user_attributes[:first_name],
          last_name: user_attributes[:last_name]
        }.merge(idx.present? ? { index: idx } : {})
        true
      end

      def validate_user_title(user_attributes, idx = nil)
        return false unless user_attributes[:title].present? && !User.titles.key?(user_attributes[:title])

        @params_validation_errors << {
          error_details: I18n.t("activerecord.errors.models.user.attributes.title.inclusion",
                                valid_values: User.titles.keys.join(", ")),
          first_name: user_attributes[:first_name],
          last_name: user_attributes[:last_name]
        }.merge(idx.present? ? { index: idx } : {})
        true
      end

      def validate_user_model(user_attributes, idx = nil)
        user = User.new(user_attributes.merge(creation_origin_attributes))
        # since it is an upsert we don't check the uniqueness validations
        user.skip_uniqueness_validations = true

        return if user.valid?

        @params_validation_errors << {
          error_details: user.errors.full_messages.to_sentence,
          first_name: user_attributes[:first_name],
          last_name: user_attributes[:last_name]
        }.merge(idx.present? ? { index: idx } : {})
      end
    end
  end
end

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
        validate_user_attributes(user_attributes.except(:referents_to_add, :tags_to_add))
        Array(user_attributes[:referents_to_add]).each { validate_referent_exists(_1[:email]) }
        Array(user_attributes[:tags_to_add]).each { validate_tag_exists(_1[:value]) }

        return if @params_validation_errors.empty?

        render json: { success: false, errors: @params_validation_errors }, status: :unprocessable_entity
      end

      def validate_users_invitations_params
        @params_validation_errors = []

        validate_users_invitations_length
        validate_users_invitations_exist

        return if @params_validation_errors.empty?

        render json: { success: false, errors: @params_validation_errors }, status: :unprocessable_entity
      end

      def validate_users_length
        return if users_attributes.length <= 25

        @params_validation_errors << {
          error_details: "Les usagers doivent être envoyés par lots de 25 maximum"
        }
      end

      def validate_users_invitations_length
        return if users_invitations_attributes.length <= 25

        @params_validation_errors << {
          error_details: "Les invitations doivent être envoyées par lots de 25 maximum"
        }
      end

      def validate_users_invitations_exist
        users_invitations_attributes.each_with_index do |attrs, idx|
          user_id = attrs[:id]
          next if @organisation.users.find_by(id: user_id)

          @params_validation_errors << {
            error_details: "Usager avec l'ID #{user_id} non trouvé dans l'organisation #{@organisation.name}",
            index: idx
          }
        end
      end

      def validate_users_attributes
        users_attributes.each_with_index do |user_attributes, idx|
          validate_user_attributes(user_attributes.except(:invitation, :referents_to_add, :tags_to_add), idx)
          Array(user_attributes[:referents_to_add]).each { validate_referent_exists(_1[:email], idx) }
          Array(user_attributes[:tags_to_add]).each { validate_tag_exists(_1[:value], idx) }
        end
      end

      def validate_referent_exists(referent_email, idx = nil)
        return if @organisation.agents.find { |agent| agent.email == referent_email }

        @params_validation_errors << {
          error_details: "Assignation du référent impossible car aucun agent n'a été retrouvé " \
                         "avec l'adresse #{referent_email} au sein de l'organisation #{@organisation.name}. "
        }.merge(idx.present? ? { index: idx } : {})
      end

      def validate_tag_exists(tag_value, idx = nil)
        return if @organisation.tags.find { |tag| tag.value == tag_value }

        @params_validation_errors << {
          error_details: "Assignation du tag impossible car aucun tag n'a été trouvé " \
                         "avec la valeur #{tag_value} au sein de l'organisation #{@organisation.name}. "
        }.merge(idx.present? ? { index: idx } : {})
      end

      def validate_user_attributes(user_attributes, idx = nil)
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

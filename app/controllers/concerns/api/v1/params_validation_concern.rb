module Api
  module V1
    module ParamsValidationConcern
      extend ActiveSupport::Concern

      private

      def validate_users_params
        @params_validation_errors = []

        validate_users_params_length
        validate_users_params_content

        return if @params_validation_errors.empty?

        render json: { success: false, errors: @params_validation_errors }, status: :unprocessable_content
      end

      def validate_user_params
        @params_validation_errors = []
        user_attrs = user_params.except(:invitation)
        validate_user_params_content(user_attrs.except(:referents_to_add, :tags_to_add))
        Array(user_attrs[:referents_to_add]).each { validate_referent_exists(it[:email]) }
        Array(user_attrs[:tags_to_add]).each { validate_tag_exists(it[:value]) }

        return if @params_validation_errors.empty?

        render json: { success: false, errors: @params_validation_errors }, status: :unprocessable_content
      end

      def validate_users_params_length
        return if users_params.length <= 25

        @params_validation_errors << {
          error_details: "Les usagers doivent être envoyés par lots de 25 maximum"
        }
      end

      def validate_users_params_content
        users_params.each_with_index do |user_params_item, idx|
          user_params = user_params_item.to_h.deep_symbolize_keys
          validate_user_params_content(user_params.except(:invitation, :referents_to_add, :tags_to_add), idx)
          Array(user_params[:referents_to_add]).each { validate_referent_exists(it[:email], idx) }
          Array(user_params[:tags_to_add]).each { validate_tag_exists(it[:value], idx) }
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
        return if @organisation.tags.find_by(value: tag_value)

        @params_validation_errors << {
          error_details: "Assignation du tag impossible car aucun tag n'a été trouvé " \
                         "avec la valeur #{tag_value} au sein de l'organisation #{@organisation.name}. "
        }.merge(idx.present? ? { index: idx } : {})
      end

      def validate_user_params_content(user_params, idx = nil)
        user = User.new(user_params.merge(creation_origin_attributes))
        # since it is an upsert we don't check the uniqueness validations
        user.skip_uniqueness_validations = true

        return if user.valid?

        @params_validation_errors << {
          error_details: user.errors.full_messages.to_sentence,
          first_name: user_params[:first_name],
          last_name: user_params[:last_name]
        }.merge(idx.present? ? { index: idx } : {})
      end
    end
  end
end

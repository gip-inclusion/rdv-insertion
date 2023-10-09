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
        validate_user_attributes(user_attributes)

        return if @params_validation_errors.empty?

        render json: { success: false, errors: @params_validation_errors }, status: :unprocessable_entity
      end

      def validate_users_length
        return if users_attributes.length <= 25

        @params_validation_errors << "Les usagers doivent être envoyés par lots de 25 maximum"
      end

      def validate_users_attributes
        users_attributes.each_with_index do |user_attributes, idx|
          validate_user_attributes(user_attributes.except(:invitation), idx)
        end
      end

      def validate_user_attributes(user_attributes, idx = nil)
        user = User.new(user_attributes)
        # since it is an upsert we don't check the uniqueness validations
        user.skip_uniqueness_validations = true

        return if user.valid?

        @params_validation_errors << {
          error_details: user.errors.to_hash,
          department_internal_id: user_attributes[:department_internal_id]
        }.merge(idx.present? ? { index: idx } : {})
      end
    end
  end
end

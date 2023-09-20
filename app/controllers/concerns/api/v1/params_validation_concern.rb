module Api
  module V1
    module ParamsValidationConcern
      extend ActiveSupport::Concern

      included do
        before_action :validate_params
      end

      private

      def validate_params
        @params_validation_errors = []

        validate_users_length
        validate_users_attributes
        validate_invitations_attributes
      end

      def validate_users_length
        return if users_attributes.length <= 25

        @params_validation_errors << "Les usagers doivent être envoyés par lots de 25 maximum"
      end

      def validate_users_attributes
        users_attributes.each_with_index do |user_attributes, idx|
          user = User.new(user_attributes.except(:invitation))
          user.skip_uniqueness_validations = true

          next if user.valid?

          department_internal_id = user_attributes[:department_internal_id]
          key = "Entrée #{idx + 1}" + (department_internal_id.present? ? " - #{department_internal_id}" : "")

          @params_validation_errors << { "#{key}": user.errors }
        end
      end

      def validate_invitations_attributes
        possible_motif_category_names = @organisation.configurations.map(&:motif_category_name)

        invitations_attributes.each_with_index do |invitation_params, idx|
          motif_category_name = invitation_params[:motif_category_name]

          if motif_category_name.blank?
            # we don't have to precise the context if there is only one context possible
            next if possible_motif_category_names.length == 1

            @params_validation_errors << {
              "Entrée #{idx + 1}": { "motif_category_name" => ["La catégorie de motifs doit être précisée"] }
            }
            next
          end

          next if motif_category_name.in?(possible_motif_category_names)

          @params_validation_errors << {
            "Entrée #{idx + 1}": { "motif_category_name" => ["Catégorie de motifs #{motif_category_name} invalide"] }
          }
        end
      end
    end
  end
end

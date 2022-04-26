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

        validate_applicants_length
        validate_applicants_attributes
        validate_invitations_params
      end

      def validate_applicants_length
        return if applicants_attributes.length <= 25

        @params_validation_errors << "Les allocataires doivent être envoyés par lots de 25 maximum"
      end

      def validate_applicants_attributes
        applicants_attributes.each_with_index do |applicant_attributes, idx|
          validator = ApplicantParamsValidator.new(applicant_attributes.except(:invitation))
          next if validator.valid?

          department_internal_id = applicant_attributes[:department_internal_id]
          key = "Entrée #{idx + 1}" + (department_internal_id.present? ? " - #{department_internal_id}" : "")

          @params_validation_errors << { "#{key}": validator.errors }
        end
      end

      def validate_invitations_params
        possible_contexts = @organisation.configurations.map(&:context)

        invitations_params.each_with_index do |invitation_params, idx|
          context = invitation_params[:context]
          # we don't have to precise the context if there is only one context possible
          next if (context.blank? && possible_contexts.length == 1) || context.in?(possible_contexts)

          @params_validation_errors << { "Entrée #{idx + 1}": "Invitation context #{context} est invalide" }
        end
      end

      class ApplicantParamsValidator
        include ActiveModel::Model
        include HasPhoneNumberConcern

        attr_accessor(*Applicant.attribute_names)

        validates_presence_of :first_name, :last_name, :title, :affiliation_number, :role, :department_internal_id
        validates :email, allow_blank: true, format: { with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/ }
        validates :role, inclusion: { in: %w[demandeur conjoint] }
        validates :title, inclusion: { in: %w[monsieur madame] }
      end
    end
  end
end

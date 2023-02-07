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
        possible_motif_category_names = @organisation.configurations.map(&:motif_category_name)

        invitations_params.each_with_index do |invitation_params, idx|
          motif_category_name = invitation_params[:motif_category_name]
          # we don't have to precise the context if there is only one context possible
          next if (motif_category_name.blank? && possible_motif_category_names.length == 1) ||
                  motif_category_name.in?(possible_motif_category_names)

          @params_validation_errors << { "Entrée #{idx + 1}": "Catégorie de motifs #{motif_category_name} invalide" }
        end
      end

      class ApplicantParamsValidator
        include ActiveModel::Model
        include Phonable

        attr_accessor(*Applicant.attribute_names)

        validates_presence_of :first_name, :last_name, :title, :affiliation_number, :role, :department_internal_id
        validates :email, allow_blank: true, format: { with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/ }
        validates :role, inclusion: { in: %w[demandeur conjoint] }
        validates :title, inclusion: { in: %w[monsieur madame] }
      end
    end
  end
end

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

        applicants_attributes.each_with_index do |applicant_attributes, idx|
          validator = ParamsValidator.new(applicant_attributes.except(:invitation))
          next if validator.valid?

          department_internal_id = applicant_attributes[:department_internal_id]
          key = "Entrée #{idx + 1}" + (department_internal_id ? " - #{department_internal_id}" : "")

          @params_validation_errors << { "#{key}": validator.errors }
        end
      end

      class ParamsValidator
        include ActiveModel::Model
        include HasPhoneNumberConcern

        attr_accessor(*Applicant.attribute_names)

        validates_presence_of :first_name, :last_name, :title, :affiliation_number, :role, :department_internal_id
        validates :email, allow_blank: true, format: { with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/ }
      end
    end
  end
end

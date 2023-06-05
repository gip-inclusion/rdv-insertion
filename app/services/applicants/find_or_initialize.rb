module Applicants
  class FindOrInitialize < BaseService
    def initialize(attributes:, department_id:)
      @attributes = attributes
      @department_id = department_id
    end

    def call
      result.applicant = matching_applicant || Applicant.new
      verify_nir_matches! if matching_applicant
    end

    private

    def matching_applicant
      @matching_applicant ||= Applicants::Find.call(
        attributes: @attributes, department_id: @department_id
      ).applicant
    end

    def verify_nir_matches!
      return if matching_applicant.nir.blank? || @attributes[:nir].blank?
      return if NirHelper.equal?(@matching_applicant.nir, @attributes[:nir])

      fail!("Le bénéficiaire #{matching_applicant.id} a les mêmes attributs mais un nir différent")
    end
  end
end

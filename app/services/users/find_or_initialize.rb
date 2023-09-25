module Users
  class FindOrInitialize < BaseService
    def initialize(attributes:, department_id:)
      @attributes = attributes
      @department_id = department_id
    end

    def call
      result.user = matching_user || User.new
      verify_nir_matches! if matching_user
    end

    private

    def matching_user
      @matching_user ||= Users::Find.call(
        attributes: @attributes, department_id: @department_id
      ).user
    end

    def verify_nir_matches!
      return if matching_user.nir.blank? || @attributes[:nir].blank?
      return if NirHelper.equal?(@matching_user.nir, @attributes[:nir])

      fail!("Le bénéficiaire #{matching_user.id} a les mêmes attributs mais un nir différent")
    end
  end
end

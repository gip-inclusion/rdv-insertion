module RdvSolidarites
  class User < Base
    RECORD_ATTRIBUTES = [
      :id, :first_name, :last_name, :birth_date, :email, :phone_number,
      :birth_name, :address, :affiliation_number
    ].freeze
    attr_reader(*RECORD_ATTRIBUTES)

    def augmented_attributes
      @attributes.merge(
        department_internal_id: applicant&.department_internal_id,
        title: applicant&.title,
        nir: applicant&.nir,
        pole_emploi_id: applicant&.pole_emploi_id
      )
    end

    def applicant
      @applicant ||= Applicant.find_by(rdv_solidarites_user_id: @id)
    end
  end
end

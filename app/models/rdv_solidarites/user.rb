module RdvSolidarites
  class User < Base
    RECORD_ATTRIBUTES = [
      :id, :first_name, :last_name, :birth_date, :email, :phone_number,
      :birth_name, :address, :affiliation_number
    ].freeze
    attr_reader(*RECORD_ATTRIBUTES)

    def augmented_attributes
      payload = applicant.nil? ? Applicant.new.as_json.merge(@attributes) : applicant.as_json.merge(@attributes)
      payload.except(:updated_at, :rdv_contexts, :organisations, :archives)
    end

    def applicant
      @applicant ||= Applicant.find_by(rdv_solidarites_user_id: @id)
    end
  end
end

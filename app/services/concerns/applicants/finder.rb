module Applicants
  module Finder
    def applicants_from_same_departments
      @applicants_from_same_departments ||= Applicant.joins(:organisations).where(
        organisations: { department_id: @applicant.department_ids }
      )
    end

    def applicants_with_same_uid
      @applicants_with_same_uid ||=
        applicants_from_same_departments.where(uid: @applicant.uid) - [@applicant]
    end

    def applicants_with_same_department_internal_id
      @applicants_with_same_department_internal_id ||=
        applicants_from_same_departments.where(department_internal_id: @applicant.department_internal_id) - [@applicant]
    end

    def applicants_with_same_email
      @applicants_with_same_email ||= Applicant.where(email: @applicant.email)
    end

    def applicants_with_same_phone_number
      @applicants_with_same_phone_number ||= Applicant.where(phone_number: @applicant.phone_number)
    end

    def applicants_with_same_email_and_first_name
      @applicants_with_same_email_and_first_name || applicants_with_same_email.select do |applicant|
        applicant.id != @applicant.id &&
          applicant.first_name.split.first.downcase == @applicant.first_name.split.first.downcase
      end
    end

    def applicants_with_same_phone_number_and_first_name
      @applicants_with_same_phone_number_and_first_name ||= applicants_with_same_phone_number.select do |applicant|
        applicant.id != @applicant.id && applicant.phone_number == @applicant.phone_number
      end
    end
  end
end

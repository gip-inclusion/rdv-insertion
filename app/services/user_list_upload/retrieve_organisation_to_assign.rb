class UserListUpload::RetrieveOrganisationToAssign < BaseService
  def initialize(user_row:)
    @user_row = user_row
  end

  def call
    retrieve_organisations_from_address!
    verify_organisations_matching_address_are_found!
    verify_assignable_organisations_are_found!
    verify_assignable_organisation_is_uniq!
    result.organisation = assignable_organisation
  end

  private

  def retrieve_organisations_from_address!
    @retrieve_organisations_from_address ||= call_service!(
      RetrieveOrganisationsFromAddress,
      address: @user_row.address, department_number: @user_row.department_number
    )
  end

  def organisations_matching_address
    @organisations_matching_address ||= @retrieve_organisations_from_address.organisations
  end

  def verify_organisations_matching_address_are_found!
    return if organisations_matching_address.any?

    fail!(
      "Aucune organisation correspondant à l'adresse de cet usager:\n" \
      "uid: #{@user_row.uid}\n" \
      "user_list_upload_id: #{@user_row.user_list_upload.id}\n" \
      "address: #{@user_row.address}\n" \
      "department_number: #{@user_row.department_number}"
    )
  end

  def verify_assignable_organisations_are_found!
    return if assignable_organisations.any?

    fail!(
      "Aucune organisation assignable pour cet usager:\n" \
      "uid: #{@user_row.uid}\n" \
      "user_list_upload_id: #{@user_row.user_list_upload.id}\n" \
      "address: #{@user_row.address}\n" \
      "department_number: #{@user_row.department_number}"
    )
  end

  def verify_assignable_organisation_is_uniq!
    return if assignable_organisations.length == 1

    fail!(
      "Plusieurs organisations possibles pour cet usager:\n" \
      "uid: #{@user_row.uid}\n" \
      "user_list_upload_id: #{@user_row.user_list_upload.id}\n" \
      "address: #{@user_row.address}\n" \
      "department_number: #{@user_row.department_number}"
    )
  end

  def assignable_organisations
    @assignable_organisations ||= (@user_row.user_list_upload_organisations & organisations_matching_address)
  end

  def assignable_organisation
    assignable_organisations.first
  end
end

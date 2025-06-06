class UserListUpload::SaveUser < BaseService
  def initialize(user_row:)
    @user_row = user_row
  end

  def call
    User.transaction do
      assign_resources_to_user
      @organisation_to_assign = @user_row.organisation_to_assign || retrieve_organisation_to_assign!
      save_user!
      result.user = saved_user
    end
    reopen_follow_up_if_closed
    unarchive_user_if_archived
  end

  private

  def user
    @user_row.user
  end

  def assign_resources_to_user
    user.referents = @user_row.referents
    user.tags = @user_row.tags
    user.assign_motif_category(@user_row.motif_category_to_assign.id) if @user_row.motif_category_to_assign
  end

  def reopen_follow_up_if_closed
    follow_up.update!(closed_at: nil) if follow_up&.closed?
  end

  def follow_up
    user.follow_up_for(@user_row.motif_category_to_assign) if @user_row.motif_category_to_assign
  end

  def unarchive_user_if_archived
    user.archive_in_organisation(@organisation_to_assign)&.destroy!
  end

  def retrieve_organisation_to_assign!
    retrieve_organisation_to_assign = UserListUpload::RetrieveOrganisationToAssign.call(user_row: @user_row)

    if retrieve_organisation_to_assign.success?
      retrieve_organisation_to_assign.organisation
    else
      result.error_type = :no_organisation_to_assign
      result.errors = retrieve_organisation_to_assign.errors
      fail!
    end
  end

  def save_user!
    @save_user ||= call_service!(
      Users::Save,
      user: user,
      organisation: @organisation_to_assign
    )
  end

  def saved_user
    @save_user.user
  end
end

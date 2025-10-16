module UserListUpload::Navigation
  extend ActiveSupport::Concern

  include Rails.application.routes.url_helpers

  def redirect_path_after_creation
    {
      file_upload: user_list_upload_path(self),
      invite_all_uninvited_button: select_rows_user_list_upload_invitation_attempts_path(self)
    }[origin.to_sym]
  end

  def structure_user_path(user_id)
    if department_level?
      department_user_path(id: user_id, department_id: structure_id)
    else
      organisation_user_path(id: user_id, organisation_id: structure_id)
    end
  end

  def structure_users_path
    if department_level?
      department_users_path(department_id: structure_id)
    else
      organisation_users_path(organisation_id: structure_id)
    end
  end

  def user_invitations_path(user_id, **)
    if department_level?
      department_user_invitations_path(department_id: structure_id, user_id:, **)
    else
      organisation_user_invitations_path(
        organisation_id: structure_id, user_id:, **
      )
    end
  end
end

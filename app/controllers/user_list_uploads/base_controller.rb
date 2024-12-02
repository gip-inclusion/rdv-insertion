class UserListUploads::BaseController < ApplicationController
  include SortParams

  private

  def sortable_attributes
    %w[first_name last_name before_user_save_status
       after_user_save_status before_invitation_status after_invitation_status]
  end
end

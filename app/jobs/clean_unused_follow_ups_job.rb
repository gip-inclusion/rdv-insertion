class CleanUnusedFollowUpsJob < ApplicationJob
  def perform(user_id)
    @user = User.find(user_id)
    call_service!(FollowUps::CleanUnused, user: @user)
  end
end

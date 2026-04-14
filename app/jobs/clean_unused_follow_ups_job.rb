class CleanUnusedFollowUpsJob < ApplicationJob
  queue_as :whenever

  def perform(user_id)
    @user = User.find(user_id)
    call_service!(FollowUps::CleanUnused, user: @user)
  end
end

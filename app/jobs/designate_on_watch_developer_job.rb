class DesignateOnWatchDeveloperJob < ApplicationJob
  DEVELOPERS_HANDLE = %w[quentin.blanc romain.neuville amine.dhobb].freeze

  def perform
    return unless production_env?

    current_on_watch_developer_handle = redis_client.get("current_on_watch_developer_handle")
    new_on_watch_developer_handle = DEVELOPERS_HANDLE[
      (DEVELOPERS_HANDLE.index(current_on_watch_developer_handle) + 1) % DEVELOPERS_HANDLE.length
    ]
    redis_client.set("current_on_watch_developer_handle", new_on_watch_developer_handle)
    MattermostClient.send_to_bug_channel(
      "@#{new_on_watch_developer_handle} est de vigie cette semaine et saura s'occuper de vous 💂!"
    )
  end

  private

  def redis_client
    @redis_client ||= Redis.new
  end
end

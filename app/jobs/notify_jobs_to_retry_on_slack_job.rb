class NotifyJobsToRetryOnSlackJob < ApplicationJob
  def perform
    SlackClient.send_to_sentry_channel(
      "*#{retry_set.size}* jobs ont échoué et sont à réessayer.\n" \
      "Ils sont répartis dans les classes suivantes:\n" \
      "#{JSON.pretty_generate(retry_set.map(&:display_class).tally)}"
    )
  end

  private

  def retry_set
    @retry_set ||= Sidekiq::RetrySet.new
  end
end

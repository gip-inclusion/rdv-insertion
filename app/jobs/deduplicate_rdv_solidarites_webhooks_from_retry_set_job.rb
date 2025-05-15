class DeduplicateRdvSolidaritesWebhooksFromRetrySetJob < ApplicationJob
  def perform(job_class_name, resource_id)
    retry_set = Sidekiq::RetrySet.new

    jobs_of_same_class = retry_set.map do |job|
      next unless job.display_class == job_class_name

      RdvSolidaritesWebhookJobWrapper.new(job)
    end.compact

    candidates = jobs_of_same_class.select do |job|
      job.valid? && job.resource_id == resource_id
    end

    return if candidates.length < 2

    job_to_keep = candidates.max_by(&:timestamp)

    candidates.each do |candidate|
      candidate.sidekiq_job.delete unless candidate == job_to_keep
    end
  end
end

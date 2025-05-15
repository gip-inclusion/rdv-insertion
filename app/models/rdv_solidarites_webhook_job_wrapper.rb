class RdvSolidaritesWebhookJobWrapper
  attr_reader :sidekiq_job

  delegate :jid, to: :sidekiq_job

  def initialize(sidekiq_job)
    @sidekiq_job = sidekiq_job
  end

  def valid?
    sidekiq_job.display_args.count == 2 && data.is_a?(Hash) && meta.is_a?(Hash) && timestamp.present?
  end

  def data
    sidekiq_job.display_args.first
  end

  def meta
    sidekiq_job.display_args.last
  end

  def resource_id
    data["id"]
  end

  def timestamp
    meta["timestamp"].is_a?(String) ? Time.zone.parse(meta["timestamp"]) : nil
  end

  def ==(other)
    jid == other.jid
  end
end

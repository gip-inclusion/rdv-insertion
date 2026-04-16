Rails.application.config.after_initialize do
  [
    Turbo::Streams::BroadcastStreamJob,
    Turbo::Streams::ActionBroadcastJob,
    Turbo::Streams::BroadcastJob
  ].each { |job| job.queue_as :within_30s }
end

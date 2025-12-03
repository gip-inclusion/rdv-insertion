class PurgeApiCallsJob < ApplicationJob
  RETENTION_PERIOD = 1.year

  def perform
    ApiCall.where(created_at: ...RETENTION_PERIOD.ago).delete_all
  end
end

module UserListUpload::Metrics
  extend ActiveSupport::Concern

  included do
    has_one :processing_log, class_name: "UserListUpload::ProcessingLog", dependent: :destroy
  end

  class_methods do
    def average_metric(uploads, metric_name)
      values = uploads.map(&:metrics).compact.map(&metric_name).compact
      return if values.empty?

      (values.sum.to_f / values.count).round(2)
    end

    def average_metrics_hash(uploads)
      uploads.first.metrics.to_h.keys.index_with do |metric_name|
        average_metric(uploads, metric_name)
      end
    end
  end

  def metrics
    @metrics ||= UserListUpload::MetricsCalculator.new(self)
  end
end

module Session
  extend ActiveSupport::Concern

  included do
    class << self
      attr_reader :uid

      private_class_method :new

      def self.with(...) = new(...)
    end
  end

  def rdv_solidarites_client
    @rdv_solidarites_client ||= RdvSolidaritesClient.new(rdv_solidarites_session: self)
  end
end

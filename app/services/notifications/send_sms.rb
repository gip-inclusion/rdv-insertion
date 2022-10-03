module Notifications
  class SendSms < BaseService
    def initialize(notification:)
      @notification = notification
    end

    def call
    end
  end
end

module CreneauOpeningRequests
  class SendEmailJob < ApplicationJob
    queue_as :whenever

    sidekiq_options retry: 10

    def perform(creneau_opening_request_id)
      creneau_opening_request = CreneauOpeningRequest.find(creneau_opening_request_id)
      return if creneau_opening_request.email_sent_at.present?

      CreneauOpeningRequestMailer.request_more_creneaux(creneau_opening_request:).deliver_now
      creneau_opening_request.update!(email_sent_at: Time.zone.now)
    end
  end
end

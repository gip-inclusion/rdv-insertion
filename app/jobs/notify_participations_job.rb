class NotifyParticipationsJob < ApplicationJob
  def perform(participation_ids, event_to_notify)
    participations = Participation.where(id: participation_ids)
    notification_event = "participation_#{event_to_notify}"
    participations.each do |participation|
      NotifyParticipationJob.perform_async(participation.id, "sms", notification_event) \
        if participation.phone_number_is_mobile?
      NotifyParticipationJob.perform_async(participation.id, "email", notification_event) \
        if participation.email?
    end
  end
end

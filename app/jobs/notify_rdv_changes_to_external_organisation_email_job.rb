class NotifyRdvChangesToExternalOrganisationEmailJob < ApplicationJob
  def perform(participation_ids, rdv_id, event)
    @rdv = Rdv.find(rdv_id)
    @participations = @rdv.participations.where(id: participation_ids).includes(:organisation)
    @category_configuration = @rdv.current_category_configuration
    @event = event

    return if !@category_configuration&.notify_rdv_changes? || already_notified?

    OrganisationMailer.notify_rdv_changes(
      to: @category_configuration.email_to_notify_rdv_changes,
      rdv: @rdv,
      participations: @participations,
      event:
    ).deliver_now
  end

  private

  def already_notified?
    cache_key = "notify_rdv_changes_#{@participations.ids.join('_')}_#{@event}"
    return true if Rails.cache.read(cache_key)

    Rails.cache.write(cache_key, true, expires_in: 1.hour)
    false
  end
end

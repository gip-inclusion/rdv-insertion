class WebhookProcessingJobError < StandardError; end

class ProcessRdvSolidaritesWebhookJob < ApplicationJob
  def perform(data, meta)
    @data = data.deep_symbolize_keys
    @meta = meta.deep_symbolize_keys
    check_organisation!
    return send_no_applicants_to_mattermost if applicants.empty?

    check_applicants_organisation!
    upsert_or_delete_rdv
    notify_applicants if should_notify_applicants?
  end

  private

  def check_organisation!
    return if organisation

    raise WebhookProcessingJobError, "Organisation not found for organisation id #{rdv_solidarites_organisation_id}"
  end

  def check_applicants_organisation!
    return if all_applicants_belongs_to_organisation?

    raise(
      WebhookProcessingJobError,
      "Applicants / Organisation mismatch: applicant_ids: #{applicant_ids} - organisation_id #{organisation.id} - " \
      "data: #{@data} - meta: #{@meta}"
    )
  end

  def send_no_applicants_to_mattermost
    MattermostClient.send_to_notif_channel(
      "Webhook not linked to RDVI applicants.\n" \
      "RDV Solidarites ids: #{rdv_solidarites_user_ids} - organisation id: #{organisation.id}\n"
    )
  end

  def should_notify_applicants?
    organisation.notify_applicant? && event.in?(%w[created destroyed])
  end

  def all_applicants_belongs_to_organisation?
    applicants.all? { |a| a.organisation_ids.include?(organisation.id) }
  end

  def event
    @meta[:event]
  end

  def rdv_solidarites_rdv
    RdvSolidarites::Rdv.new(@data)
  end

  def rdv_solidarites_user_ids
    rdv_solidarites_rdv.user_ids
  end

  def applicants
    @applicants ||= Applicant.where(rdv_solidarites_user_id: rdv_solidarites_user_ids)
  end

  def applicant_ids
    applicants.pluck(:id)
  end

  def organisation
    @organisation ||= Organisation.find_by(rdv_solidarites_organisation_id: rdv_solidarites_organisation_id)
  end

  def rdv_solidarites_organisation_id
    @data[:organisation][:id]
  end

  def upsert_or_delete_rdv
    if event == "destroyed"
      DeleteRdvJob.perform_async(rdv_solidarites_rdv.id)
    else
      UpsertRecordJob.perform_async(Rdv, @data, { applicant_ids: applicant_ids, organisation_id: organisation.id })
    end
  end

  def notify_applicants
    applicants.each do |applicant|
      NotifyApplicantJob.perform_async(
        applicant.id,
        organisation.id,
        @data,
        event
      )
    end
  end
end

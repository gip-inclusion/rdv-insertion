class WebhookProcessingJobError < StandardError; end

class ProcessRdvSolidaritesWebhookJob < ApplicationJob
  def perform(data, meta)
    @data = data.deep_symbolize_keys
    @meta = meta.deep_symbolize_keys
    check_department!
    return send_no_applicants_to_mattermost if applicants.empty?

    check_applicants_department!
    upsert_or_delete_rdv
    notify_applicants if should_notify_applicants?
  end

  private

  def check_department!
    return if department

    raise WebhookProcessingJobError, "Department not found for organisation id #{rdv_solidarites_organisation_id}"
  end

  def check_applicants_department!
    return if applicants.length == 1 && applicants.first.department_id == department.id

    raise(
      WebhookProcessingJobError,
      "Applicants / Department mismatch: applicant_ids: #{applicant_ids} - department_id #{department.id} - " \
      "data: #{@data} - meta: #{@meta}"
    )
  end

  def send_no_applicants_to_mattermost
    MattermostClient.send_to_notif_channel(
      "Webhook not linked to RDVI applicants.\n" \
      "RDV Solidarites ids: #{rdv_solidarites_user_ids} - Department id: #{department.id}\n"
    )
  end

  def should_notify_applicants?
    department.notify_applicant? && event.in?(%w[created destroyed])
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
    @applicants ||= Applicant.includes(:department).where(rdv_solidarites_user_id: rdv_solidarites_user_ids)
  end

  def applicant_ids
    applicants.pluck(:id)
  end

  def department
    @department ||= Department.find_by(rdv_solidarites_organisation_id: rdv_solidarites_organisation_id)
  end

  def rdv_solidarites_organisation_id
    @data[:organisation][:id]
  end

  def upsert_or_delete_rdv
    if event == "destroyed"
      DeleteRdvJob.perform_async(rdv_solidarites_rdv.id)
    else
      UpsertRdvJob.perform_async(@data, applicant_ids, department.id)
    end
  end

  def notify_applicants
    applicants.each do |applicant|
      NotifyApplicantJob.perform_async(
        applicant.id,
        @data,
        event
      )
    end
  end
end

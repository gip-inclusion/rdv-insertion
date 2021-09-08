class WebhookProcessingJobError < StandardError; end

class ProcessRdvSolidaritesWebhookJob < ApplicationJob
  def perform(data, meta)
    @data = data.deep_symbolize_keys
    @meta = meta.deep_symbolize_keys
    validate_data!
    notify_applicant if should_notify_applicant?
  end

  private

  def validate_data!
    raise WebhookProcessingJobError, "Department not found" unless department
    raise WebhookProcessingJobError, "Applicant not found" unless applicant
    raise WebhookProcessingJobError, "Applicant / Department mismatch" if applicant.department.id != department.id
  end

  def should_notify_applicant?
    department.notify_applicant? && @meta[:model] == "Rdv"
  end

  def applicant
    @applicant ||= Applicant.includes(:department).where(rdv_solidarites_user_id: @data[:users].pluck(:id)).first
  end

  def department
    @department ||= Department.find_by(rdv_solidarites_organisation_id: @data[:organisation][:id])
  end

  def notify_applicant
    NotifyApplicantJob.perform_async(
      applicant.id,
      @data[:lieu],
      @data[:motif],
      @data[:starts_at],
      @meta[:event]
    )
  end
end

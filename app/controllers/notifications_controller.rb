class NotificationsController < ApplicationController
  before_action :set_participation

  def create
    if notify_participation.success?
      respond_to do |format|
        format.pdf { send_data pdf, filename: pdf_filename, layout: "application/pdf" }
      end
    else
      render turbo_stream: turbo_stream.replace(
        "remote_modal", partial: "common/error_modal", locals: {
          errors: notify_participation.errors
        }
      )
    end
  end

  private

  def set_participation
    @participation = Participation.find(params[:participation_id])
    authorize @participation
  end

  def notification_params
    params.require(:notification).permit(:format, :event)
  end

  def notify_participation
    @notify_participation ||= Notifications::NotifyParticipation.call(
      participation: @participation,
      format: notification_params[:format],
      event: notification_params[:event]
    )
  end

  def pdf
    WickedPdf.new.pdf_from_string(notify_participation.notification.content, encoding: "utf-8")
  end

  def pdf_filename
    "Convocation_de_#{applicant.first_name}_#{applicant.last_name}_le_#{rdv.formatted_start_date}.pdf"
  end

  def applicant
    @participation.applicant
  end

  def rdv
    @participation.rdv
  end
end

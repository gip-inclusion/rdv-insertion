class NotificationsController < ApplicationController
  before_action :set_participation

  def create
    if notify_participation.success?
      respond_to do |format|
        format.pdf { pdf.present? ? send_pdf_data : handle_pdf_generation_error }
      end
    else
      respond_to do |format|
        format.pdf do
          flash[:error] = notify_participation.errors.join(", ")
          redirect_to request.referer
        end
      end
    end
  end

  private

  def set_participation
    @participation = Participation.find(params[:participation_id])
    authorize @participation
  end

  def notification_params
    params.expect(notification: [:format, :event])
  end

  def notify_participation
    @notify_participation ||= Notifications::SaveAndSend.call(
      participation: @participation,
      format: notification_params[:format],
      event: notification_params[:event]
    )
  end

  def send_pdf_data
    send_data pdf, filename: pdf_filename, layout: "application/pdf"
  end

  def handle_pdf_generation_error
    flash[:error] = "Une erreur est survenue lors de la génération du PDF." \
                    " L'équipe a été notifiée de l'erreur et tente de la résoudre."
    redirect_to request.referer
  end

  def pdf
    response = PdfGeneratorClient.generate_pdf(content: notify_participation.notification.content)
    if response.success?
      Base64.decode64(response.body)
    else
      Sentry.capture_message(
        "PDF generation failed",
        extra: {
          status: response.status,
          body: response.body,
          notification_id: notify_participation.notification.id
        }
      )
      nil
    end
  end

  def pdf_filename
    "Convocation_de_#{user.first_name}_#{user.last_name}_le_#{rdv.formatted_start_date}.pdf"
  end

  def user
    @participation.user
  end

  def rdv
    @participation.rdv
  end
end

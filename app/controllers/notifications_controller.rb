class NotificationsController < ApplicationController
  before_action :set_participation

  def create
    if notify_participation.success?
      respond_to do |format|
        format.pdf { send_data pdf, filename: pdf_filename, layout: "application/pdf" }
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
    params.require(:notification).permit(:format, :event)
  end

  def notify_participation
    @notify_participation ||= Notifications::SaveAndSend.call(
      participation: @participation,
      format: notification_params[:format],
      event: notification_params[:event]
    )
  end

  def pdf
    Grover.new(notify_participation.notification.content, format: "A4", print_background: true).to_pdf
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

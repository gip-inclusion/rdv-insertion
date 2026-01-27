class InvitationsController < ApplicationController
  layout "invited_user", only: [:invitation_code, :redirect]
  before_action :set_organisations, :set_user, :ensure_rdv_solidarites_user_exists, only: [:create]
  before_action :set_invitation, :set_organisations_with_contact, :verify_invitation_validity, only: [:redirect]
  skip_before_action :authenticate_agent!, only: [:invitation_code, :redirect, :redirect_shortcut]

  def create # rubocop:disable Metrics/AbcSize
    if invite_user.success?
      respond_to do |format|
        format.json { render json: { success: true, invitation: invitation } }
        format.pdf { pdf.present? ? send_pdf_data : handle_pdf_generation_error }
        format.turbo_stream { redirect_to structure_user_follow_ups_path(user_id: @user.id) }
      end
    else
      respond_to do |format|
        format.pdf do
          render json: { success: false, errors: invite_user.errors }, status: :unprocessable_content
        end
        format.json do
          render json: {
            success: false,
            # En cas d'erreur, le serveur renvoie un JSON contenant un champ turbo_stream_html qui correspond à un HTML
            #   sous forme de string, généré avec un stream Turbo (via turbo_stream.replace).
            # Une fois le JSON reçu, le client parse la réponse et applique le Turbo stream en utilisant
            #   window.Turbo.renderStreamMessage.
            # Discussion ici : https://github.com/gip-inclusion/rdv-insertion/pull/2361#discussion_r1784538358
            turbo_stream_html: turbo_stream.replace("remote_modal", partial: "common/custom_errors_modal",
                                                                    locals: { errors: invite_user.errors,
                                                                              title: "Impossible d'inviter l'usager" })
          }, status: :unprocessable_content
        end
        format.turbo_stream do
          turbo_stream_display_custom_error_modal(errors: invite_user.errors, title: "Impossible d'inviter l'usager")
        end
      end
    end
  end

  def invitation_code; end

  def redirect_shortcut
    redirect_to redirect_invitations_path(params: { uuid: params[:uuid] })
  end

  def redirect
    @invitation.clicked = true
    @invitation.save
    redirect_to @invitation.link, allow_other_host: true
  end

  private

  def invitation_params
    params.expect(
      invitation: [:format, :rdv_solidarites_lieu_id, { motif_category: [:id] }]
    ).to_h.deep_symbolize_keys
  end

  def invitation = invite_user.invitation

  def invite_user
    @invite_user ||= InviteUser.call(
      user: @user,
      organisations: @organisations,
      invitation_attributes: invitation_params.except(:motif_category),
      motif_category_attributes: invitation_params[:motif_category] || {}
    )
  end

  def send_pdf_data
    send_data pdf, filename: pdf_filename, layout: "application/pdf"
  end

  def handle_pdf_generation_error
    render json: {
             success: false,
             errors: [
               "Une erreur est survenue lors de la génération du PDF.
               L'équipe a été notifiée de l'erreur et tente de la résoudre."
             ]
           },
           status: :internal_server_error
  end

  def pdf
    response = PdfGeneratorClient.generate_pdf(content: invitation.content)
    if response.success?
      Base64.decode64(response.body)
    else
      Sentry.capture_message(
        "PDF generation failed",
        extra: {
          status: response.status,
          body: response.body,
          invitation_id: invitation.id
        }
      )
      nil
    end
  end

  def pdf_filename
    "Invitation_#{Time.now.to_i}_#{@user.last_name}_#{@user.first_name}.pdf"
  end

  def set_organisations
    @organisations =
      policy_scope(Organisation)
      .preload(:motif_categories, :department, :messages_configuration)
      .where(department_level? ? { department_id: params[:department_id] } : { id: params[:organisation_id] })
      .joins(:motif_categories).where(motif_categories: { id: invitation_params.dig(:motif_category, :id) })
  end

  def set_organisations_with_contact
    @organisations_with_contact = @invitation.organisations.select do |org|
      org.phone_number.present? || org.email.present?
    end
  end

  def set_user
    @user = policy_scope(User).includes(:invitations).find(params[:user_id])
  end

  def ensure_rdv_solidarites_user_exists
    recreate_rdv_solidarites_user(@user) if @user.rdv_solidarites_user_id.nil?
  end

  def set_invitation
    @invitation = Invitation.find_by(uuid: params[:uuid])
    return if @invitation.present?

    redirect_to(:invitation_landing, flash: { error: "Ce code n'existe pas dans notre système." })
  end

  def verify_invitation_validity
    return unless @invitation.expired?

    render :invalid
  end
end

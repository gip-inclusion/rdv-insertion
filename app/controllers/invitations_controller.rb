class InvitationsController < ApplicationController
  before_action :set_organisations, :set_user, only: [:create]
  before_action :set_invitation, :verify_invitation_validity, only: [:redirect]
  skip_before_action :authenticate_agent!, only: [:invitation_code, :redirect]

  def create
    if invite_user.success?
      respond_to do |format|
        format.json { render json: { success: true, invitation: invitation } }
        format.pdf { send_data pdf, filename: pdf_filename, layout: "application/pdf" }
      end
    else
      render json: { success: false, errors: invite_user.errors }, status: :unprocessable_entity
    end
  end

  def invitation_code; end

  def redirect
    @invitation.clicked = true
    @invitation.save
    redirect_to @invitation.link
  end

  private

  def invitation_params
    params.require(:invitation).permit(
      :format, :help_phone_number, :rdv_solidarites_lieu_id, { motif_category: [:id] }
    ).to_h.deep_symbolize_keys
  end

  def invitation = invite_user.invitation

  def invite_user
    @invite_user ||= InviteUser.call(
      user: @user,
      organisations: @organisations,
      invitation_attributes: invitation_params.except(:motif_category),
      motif_category_attributes: invitation_params[:motif_category] || {},
      rdv_solidarites_session:
    )
  end

  def pdf
    WickedPdf.new.pdf_from_string(invitation.content, encoding: "utf-8")
  end

  def pdf_filename
    "Invitation_#{Time.now.to_i}_#{@user.last_name}_#{@user.first_name}.pdf"
  end

  def set_organisations
    @organisations =
      policy_scope(Organisation)
      .includes(:motif_categories, :department, :messages_configuration)
      .where(department_level? ? { department_id: params[:department_id] } : { id: params[:organisation_id] })
  end

  def set_user
    @user = policy_scope(User).includes(:invitations).find(params[:user_id])
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

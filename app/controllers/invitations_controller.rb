class InvitationsController < ApplicationController
  before_action :set_organisations, :set_organisation, :set_department, :set_applicant, :set_rdv_context,
                :set_current_configuration, :set_invitation_format, :set_new_invitation,
                :set_invitation_validity_duration, only: [:create]
  before_action :set_invitation, only: [:redirect]
  skip_before_action :authenticate_agent!, only: [:invitation_code, :redirect]

  def create # rubocop:disable Metrics/AbcSize
    if save_and_send_invitation.success?
      respond_to do |format|
        format.json { render json: { success: true, invitation: @invitation } }
        format.pdf { send_data pdf, filename: pdf_filename, layout: "application/pdf" }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.json { render json: { success: false, errors: save_and_send_invitation.errors } }
        format.turbo_stream do
          flash[:error] = save_and_send_invitation.errors.join(", ")
          redirect_to request.referer
        end
      end
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
    params.permit(
      :invitation_format, :help_phone_number, :rdv_solidarites_lieu_id, :motif_category
    )
  end

  def set_new_invitation
    @invitation = Invitation.new(
      applicant: @applicant,
      department: @department,
      organisations: @organisations,
      rdv_context: @rdv_context,
      format: @invitation_format,
      number_of_days_to_accept_invitation: @current_configuration.number_of_days_to_accept_invitation,
      help_phone_number: invitation_params[:help_phone_number],
      rdv_solidarites_lieu_id: invitation_params[:rdv_solidarites_lieu_id]
    )
    authorize @invitation
  end

  def set_invitation_format
    @invitation_format = invitation_params[:invitation_format]
  end

  def pdf
    WickedPdf.new.pdf_from_string(@invitation.content, encoding: "utf-8")
  end

  def pdf_filename
    "Invitation_#{Time.now.to_i}_#{@applicant.last_name}_#{@applicant.first_name}.pdf"
  end

  def save_and_send_invitation
    @save_and_send_invitation ||= Invitations::SaveAndSend.call(
      invitation: @invitation,
      rdv_solidarites_session: rdv_solidarites_session
    )
  end

  def set_organisations
    @organisations = \
      if department_level?
        policy_scope(Organisation).where(department_id: params[:department_id])
      else
        policy_scope(Organisation).where(id: params[:organisation_id])
      end
  end

  def set_organisation
    return if department_level?

    @organisation = @organisations.first
  end

  def set_rdv_context
    RdvContext.with_advisory_lock "setting_rdv_context_for_applicant_#{@applicant.id}" do
      @rdv_context = RdvContext.find_or_create_by!(
        motif_category: motif_category, applicant: @applicant
      )
    end
  end

  def set_current_configuration
    @current_configuration = @organisations.flat_map(&:configurations).find { |c| c.motif_category == motif_category }
  end

  def motif_category
    invitation_params[:motif_category]
  end

  # the validity of an invitation is equal to the number of days before an action is required, unless it's postal
  def set_invitation_validity_duration
    @invitation.validity_duration = \
      @invitation.format_postal? ? nil : @current_configuration.number_of_days_before_action_required.days
  end

  def set_department
    @department = @organisations.first.department
  end

  def set_applicant
    @applicant = policy_scope(Applicant).includes(:invitations).find(params[:applicant_id])
  end

  def set_invitation
    # TODO: identify the invitation with a uuid
    @invitation = Invitation.where(format: invitation_format, token: params[:token]).last
    raise ActiveRecord::RecordNotFound unless @invitation
  end

  def invitation_format
    params[:format] || "sms" # sms by default to keep the sms link the shortest possible
  end
end

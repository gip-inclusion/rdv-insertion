class InvitationsController < ApplicationController
  before_action :set_organisations, :set_department, :set_user,
                :set_motif_category, :set_rdv_context, :set_current_configuration,
                :set_invitation_format, :set_preselected_organisations, :set_new_invitation,
                only: [:create]
  before_action :set_invitation, :verify_invitation_validity, only: [:redirect]
  skip_before_action :authenticate_agent!, only: [:invitation_code, :redirect]

  def create
    if save_and_send_invitation.success?
      respond_to do |format|
        format.json { render json: { success: true, invitation: @invitation } }
        format.pdf { send_data pdf, filename: pdf_filename, layout: "application/pdf" }
      end
    else
      render json: { success: false, errors: save_and_send_invitation.errors }, status: :unprocessable_entity
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
      :invitation_format, :help_phone_number, :rdv_solidarites_lieu_id, :motif_category_id
    )
  end

  def set_new_invitation
    @invitation = Invitation.new(
      user: @user,
      department: @department,
      organisations: @preselected_organisations,
      rdv_context: @rdv_context,
      format: @invitation_format,
      help_phone_number: invitation_params[:help_phone_number],
      rdv_solidarites_lieu_id: invitation_params[:rdv_solidarites_lieu_id],
      # the validity of an invitation is equal to the number of days before an action is required,
      # then the organisation usually convene the user
      valid_until: @current_configuration.number_of_days_before_action_required.days.from_now,
      rdv_with_referents: @current_configuration.rdv_with_referents
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
    "Invitation_#{Time.now.to_i}_#{@user.last_name}_#{@user.first_name}.pdf"
  end

  def save_and_send_invitation
    update_creneaux_call = Configurations::UpdateAvailableCreneauxCount.call(
      configuration: @current_configuration,
      rdv_solidarites_session: rdv_solidarites_session
    )


    # Tester en batch invitations (une seule requete pour plusieurs invitations)
    # Testing
    # réduire la taille de ce fichier
    # on bloque la possibilité d'envoyer une invitation sur les pages index / show / UPLOAD avec un message explicatif dans une box
    # Demander une précision pour les rdv collectifs

    # Search Context à refactoriser en d'autres classes et services, on va utiliser les memes params
    # Vérifier individuellement l'invitation dans le search context
    # Service pour le filter_motifs ?...
    # créneaux disponibles doit renvoyer des creneaux ?

    if update_creneaux_call.fails?
      OpenStruct.new(success?: false, errors: update_creneaux_call.errors)
    elsif @current_configuration.available_creneaux_count.zero?
      OpenStruct.new(
        success?: false,
        errors: [
          "L'envoi d'une invitation est impossible car il n'y a plus de créneaux disponibles.
          Nous invitons donc à créer de nouvelles plages d'ouverture depuis l'interface
          RDV-Solidarités pour pouvoir à nouveau envoyer des invitations"
        ]
      )
    else
      @save_and_send_invitation ||= Invitations::SaveAndSend.call(
        invitation: @invitation,
        rdv_solidarites_session: rdv_solidarites_session
      )
    end
  end

  def set_organisations
    @organisations =
      policy_scope(Organisation)
      .includes(:motif_categories, :department, :messages_configuration)
      .where(department_level? ? { department_id: params[:department_id] } : { id: params[:organisation_id] })
  end

  def set_rdv_context
    RdvContext.with_advisory_lock "setting_rdv_context_for_user_#{@user.id}" do
      @rdv_context = RdvContext.find_or_create_by!(
        motif_category: @motif_category, user: @user
      )
    end
  end

  def set_preselected_organisations
    @preselected_organisations =
      @current_configuration.invite_to_user_organisations_only? ? @organisations & @user.organisations : @organisations
  end

  def set_current_configuration
    @current_configuration = @organisations.where(id: @user.organisations)
                                           .preload(:configurations)
                                           .flat_map(&:configurations)
                                           .find { |c| c.motif_category == @motif_category }
  end

  def set_motif_category
    @motif_category = MotifCategory.find(invitation_params[:motif_category_id])
  end

  def set_department
    @department = @organisations.first.department
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

  def invitation_format
    params[:format] || "sms" # sms by default to keep the sms link the shortest possible
  end
end

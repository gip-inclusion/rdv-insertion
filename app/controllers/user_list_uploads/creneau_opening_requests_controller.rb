module UserListUploads
  class CreneauOpeningRequestsController < BaseController
    before_action :set_user_list_upload, only: [:new, :create_many]

    def new
      @available_creneaux_count = available_creneaux_count
      @users_to_invite_count = users_to_invite_count
      @missing_creneaux_count = @users_to_invite_count - @available_creneaux_count
      @recipient_agents = recipient_agents
    end

    def create_many
      if create_requests.success?
        turbo_stream_display_success_modal(
          success_message,
          title: "Demande d'ouverture de créneaux envoyée",
          tally_form_id: ENV["CRENEAU_OPENING_REQUEST_TALLY_ID"]
        )
      else
        turbo_stream_replace_error_list_with(create_requests.errors)
      end
    end

    private

    def set_user_list_upload
      @user_list_upload = UserListUpload.find(params[:user_list_upload_id])
      authorize @user_list_upload, :edit?
    end

    def recipient_agents
      Agent.joins(:agent_roles)
           .where(agent_roles: { organisation_id: @user_list_upload.structure_organisations.map(&:id) })
           .with_last_name
           .distinct
           .order(:last_name, :first_name)
    end

    def available_creneaux_count
      params[:available_creneaux_count].to_i
    end

    def users_to_invite_count
      params[:users_to_invite_count].to_i
    end

    def create_requests
      @create_requests ||= CreneauOpeningRequests::CreateMany.call(
        user_list_upload: @user_list_upload,
        recipient_agent_ids: submitted_recipient_agent_ids,
        available_creneaux_count: available_creneaux_count,
        users_to_invite_count: users_to_invite_count
      )
    end

    def submitted_recipient_agent_ids
      Array(params[:recipient_agent_ids]).compact_blank.map(&:to_i)
    end

    def success_message
      count = create_requests.creneau_opening_requests.length
      "Votre demande a été envoyée à #{helpers.pluralize(count, 'agent destinataire')}."
    end
  end
end

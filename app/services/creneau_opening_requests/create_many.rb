module CreneauOpeningRequests
  class CreateMany < BaseService
    def initialize(user_list_upload:, recipient_agent_ids:, available_creneaux_count:, users_to_invite_count:)
      @user_list_upload = user_list_upload
      @recipient_agent_ids = recipient_agent_ids
      @available_creneaux_count = available_creneaux_count
      @users_to_invite_count = users_to_invite_count
    end

    def call
      fail!("Aucun agent destinataire sélectionné") if @recipient_agent_ids.blank?
      fail!("Un ou plusieurs destinataires ne sont pas autorisés") if unauthorized_recipient_ids.any?

      CreneauOpeningRequest.transaction do
        result.creneau_opening_requests = @recipient_agent_ids.map { |id| build_and_save!(id) }
      end
    end

    private

    def unauthorized_recipient_ids
      @recipient_agent_ids.map(&:to_i) - authorized_recipient_ids
    end

    def authorized_recipient_ids
      Agent.joins(:agent_roles)
           .where(agent_roles: { organisation_id: @user_list_upload.structure_organisations.map(&:id) })
           .with_last_name
           .where(id: @recipient_agent_ids)
           .pluck(:id)
    end

    def build_and_save!(recipient_agent_id)
      creneau_opening_request = CreneauOpeningRequest.new(
        user_list_upload: @user_list_upload,
        recipient_agent_id: recipient_agent_id,
        users_to_invite_count: @users_to_invite_count,
        available_creneaux_count: @available_creneaux_count,
        link: link
      )
      save_record!(creneau_opening_request)
      creneau_opening_request
    end

    def link
      @link ||= if @user_list_upload.department_level?
                  ENV.fetch("RDV_SOLIDARITES_URL")
                else
                  "#{ENV.fetch('RDV_SOLIDARITES_URL')}/admin/organisations/" \
                    "#{@user_list_upload.organisation.rdv_solidarites_organisation_id}/planning/plage_ouvertures"
                end
    end
  end
end

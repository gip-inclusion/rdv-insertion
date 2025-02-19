module ModalAgreementsConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_should_display_accept_cgu, if: -> { request.get? }
    before_action :set_should_display_accept_dpa, if: -> { request.get? }
  end

  private

  def set_should_display_accept_cgu
    @should_display_accept_cgu = should_accept_cgu?
  end

  def should_accept_cgu?
    return false if current_agent.nil?
    return false if agent_impersonated?

    current_agent.cgu_accepted_at.nil?
  end

  def set_should_display_accept_dpa
    @should_display_accept_dpa = should_accept_dpa?
  end

  def should_accept_dpa?
    return false if current_agent.nil?
    return false if agent_impersonated?
    # If params[:organisation_id] is nil, it means that
    # the agent is not actively browsing the current_organisation
    # in which case we don't want to display the DPA modal
    # to avoid any confusion
    return false if params[:organisation_id].nil?
    return false if current_organisation.created_at > 1.month.ago

    current_organisation.requires_dpa_acceptance? && policy(current_organisation).can_accept_dpa?
  end
end

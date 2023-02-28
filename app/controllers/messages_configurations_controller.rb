class MessagesConfigurationsController < ApplicationController
  PERMITTED_PARAMS = [
    { direction_names: [] }, :sender_city, :letter_sender_name, { signature_lines: [] }, :help_address,
    :display_europe_logos, :display_department_logo, :sms_sender_name
  ].freeze

  before_action :set_organisation, :set_messages_configuration, only: [:show, :edit, :update]

  def show; end

  def edit; end

  def update
    @messages_configuration.assign_attributes(**formatted_params)
    if @messages_configuration.save
      render :show
    else
      flash.now[:error] = @messages_configuration.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def messages_configuration_params
    params.require(:messages_configuration).permit(*PERMITTED_PARAMS).to_h.deep_symbolize_keys
  end

  def formatted_params
    # we nullify some blank params for unicity exceptions (ActiveRecord::RecordNotUnique) not to raise
    messages_configuration_params.to_h do |k, v|
      [k, k.in?([:sms_sender_name]) ? v.presence : v]
    end
  end

  def set_messages_configuration
    @messages_configuration = policy_scope(MessagesConfiguration).find(params[:id])
  end

  def set_organisation
    @organisation = policy_scope(Organisation).find(params[:organisation_id])
    authorize @organisation, :configure?
  end
end

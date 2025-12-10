class TagsController < ApplicationController
  before_action :set_organisation

  def create
    tag = Tag.joins(:tag_organisations).find_by(
      tag_organisations: { organisation_id: @organisation.department.organisation_ids },
      value: tag_params[:value]
    ) || Tag.create!(tag_params)

    @organisation.tags << tag

    redirect_to organisation_configuration_tags_path(@organisation)
  rescue ActiveRecord::ActiveRecordError => e
    turbo_stream_display_error_modal(e.record.errors.full_messages)
  end

  def destroy
    tag = Tag.find(params[:id])
    tag.organisations.delete(@organisation.id)

    tag.destroy! unless tag.organisations.any?

    render turbo_stream: turbo_stream.remove("tag_#{tag.id}")
  end

  private

  def set_organisation
    @organisation = current_organisation
    authorize @organisation, :configure?
  end

  def tag_params
    params.expect(tag: [:value])
  end
end

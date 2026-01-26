class CsvExportMailer < ApplicationMailer
  def notify_csv_export(email, export)
    @export = export
    @request_params = @export.request_params&.deep_symbolize_keys
    set_organisations_filter
    set_request_filters if @request_params.present?
    mail(to: email, subject: "[rdv-insertion] Export CSV")
  end

  private

  def set_request_filters
    set_follow_up_statuses_filter
    set_referents_filter
    set_creation_dates_filter
    set_invitation_dates_filter
    set_tags_filter
    set_motif_category_filter
    set_action_required_filter
    set_search_query_filter
  end

  def set_organisations_filter
    @organisations_filter =
      if @export.structure_type == "Organisation"
        [Organisation.find(@export.structure_id)]
      else
        Agent.find(@export.agent_id).organisations.where(department: @export.structure_id)
      end
  end

  def set_follow_up_statuses_filter
    @follow_up_statuses_filter = @request_params[:follow_up_statuses]
  end

  def set_referents_filter
    @referents_filter = @request_params[:referent_ids].present? ? Agent.where(id: @request_params[:referent_ids]) : nil
  end

  def set_creation_dates_filter
    @creation_date_before = @request_params[:creation_date_before]
    @creation_date_after = @request_params[:creation_date_after]
  end

  def set_invitation_dates_filter
    @first_invitation_date_before = @request_params[:first_invitation_date_before]
    @first_invitation_date_after = @request_params[:first_invitation_date_after]
    @last_invitation_date_before = @request_params[:last_invitation_date_before]
    @last_invitation_date_after = @request_params[:last_invitation_date_after]
  end

  def set_tags_filter
    @tags_filter = @request_params[:tag_ids].present? ? Tag.where(id: @request_params[:tag_ids]).sort_by(&:value) : nil
  end

  def set_motif_category_filter
    @motif_category_filter =
      @request_params[:motif_category_id].present? ? MotifCategory.find(@request_params[:motif_category_id]) : nil
  end

  def set_action_required_filter
    @action_required_filter = @request_params[:action_required]
  end

  def set_search_query_filter
    @search_query_filter = @request_params[:search_query]
  end
end

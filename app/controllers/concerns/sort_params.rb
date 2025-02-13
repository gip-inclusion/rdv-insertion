module SortParams
  extend ActiveSupport::Concern

  included do
    helper_method :sort_params
  end

  private

  def sort_params
    { sort_by:, sort_direction: }
  end

  def sort_params?
    sort_by && sort_direction
  end

  def sort_params_valid?
    sort_params? && sort_by.in?(sortable_attributes) && sort_direction.in?(%w[asc desc])
  end

  def sort_by
    params[:sort_by]
  end

  def sort_direction
    params[:sort_direction]
  end

  def sortable_attributes
    raise NoMethodError
  end
end

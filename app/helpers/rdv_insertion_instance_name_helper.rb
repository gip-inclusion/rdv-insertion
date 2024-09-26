module RdvInsertionInstanceNameHelper
  def rdv_insertion_instance_name
    return if production_env?

    if Rails.env.development?
      Rails.env
    elsif ENV["HOST"].include?("staging")
      "Staging"
    else
      "Démo"
    end
  end
end

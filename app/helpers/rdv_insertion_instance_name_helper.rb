module RdvInsertionInstanceNameHelper
  def rdv_insertion_instance_name
    return if production_env?

    if Rails.env.development?
      Rails.env
    else
      "Démo"
    end
  end
end

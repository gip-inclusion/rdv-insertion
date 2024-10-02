module RdvInsertionInstanceNameHelper
  def rdv_insertion_instance_name
    if local_env?
      "Local"
    elsif staging_env?
      "Staging"
    elsif demo_env?
      "Démo"
    end
  end
end

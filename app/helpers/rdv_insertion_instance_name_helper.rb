module RdvInsertionInstanceNameHelper
  def rdv_insertion_instance_name
    if development_env?
      "Développement"
    elsif staging_env?
      "Staging"
    elsif demo_env?
      "Démo"
    end
  end
end

module RdvInsertionInstanceNameHelper
  def rdv_insertion_instance_name
    if EnvironmentsHelper.development_env?
      "Développement"
    elsif EnvironmentsHelper.staging_env?
      "Staging"
    elsif EnvironmentsHelper.demo_env?
      "Démo"
    end
  end
end

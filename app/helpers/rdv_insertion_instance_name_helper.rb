module RdvInsertionInstanceNameHelper
  def rdv_insertion_instance_name
    if ENV["RDV_INSERTION_INSTANCE_NAME"].present?
      ENV["RDV_INSERTION_INSTANCE_NAME"]
    elsif Rails.env.development?
      Rails.env
    end
  end
end

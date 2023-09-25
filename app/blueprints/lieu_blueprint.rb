class LieuBlueprint < Blueprinter::Base
  # To delete after BDR make the change
  if ENV["ROLLOUT_NEW_API_VERSION"] == "1"
    identifier :id
  else
    identifier :rdv_solidarites_lieu_id, name: :id
  end
  fields :name, :address, :phone_number
end

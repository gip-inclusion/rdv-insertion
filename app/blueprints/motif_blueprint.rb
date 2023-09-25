class MotifBlueprint < Blueprinter::Base
  # To delete after BDR make the change
  if ENV["ROLLOUT_NEW_API_VERSION"] == "1"
    identifier :id
  else
    identifier :rdv_solidarites_motif_id, name: :id
  end
  fields :name, :collectif, :location_type, :follow_up
  association :motif_category, blueprint: MotifCategoryBlueprint
end

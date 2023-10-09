class MotifBlueprint < Blueprinter::Base
  identifier :id
  fields :name, :collectif, :location_type, :follow_up, :rdv_solidarites_motif_id
  association :motif_category, blueprint: MotifCategoryBlueprint
end

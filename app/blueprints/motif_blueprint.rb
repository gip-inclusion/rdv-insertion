class MotifBlueprint < Blueprinter::Base
  identifier :rdv_solidarites_motif_id
  fields :name, :collectif, :location_type, :follow_up
  association :motif_category, blueprint: MotifCategoryBlueprint
end

class MotifBlueprint < Blueprinter::Base
  identifier :id
  fields :name, :collectif, :location_type, :follow_up
  association :motif_category, blueprint: MotifCategoryBlueprint
end

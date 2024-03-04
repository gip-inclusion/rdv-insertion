class InvitationBlueprint < Blueprinter::Base
  identifier :id
  fields :format, :clicked, :rdv_with_referents, :created_at
  association :motif_category, blueprint: MotifCategoryBlueprint

  view :extended do
    association :user, blueprint: UserBlueprint
  end
end

class InvitationBlueprint < Blueprinter::Base
  identifier :id
  fields :format, :sent_at, :clicked, :rdv_with_referents
  association :motif_category, blueprint: MotifCategoryBlueprint

  view :extended do
    association :user, blueprint: UserBlueprint
  end
end

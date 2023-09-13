class InvitationBlueprint < Blueprinter::Base
  identifier :id
  fields :format, :sent_at, :clicked, :rdv_with_referents

  view :extended do
    association :motif_category, blueprint: MotifCategoryBlueprint
    association :applicant, blueprint: ApplicantBlueprint
  end
end

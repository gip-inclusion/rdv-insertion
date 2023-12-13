class LieuBlueprint < Blueprinter::Base
  identifier :rdv_solidarites_lieu_id
  fields :name, :address, :phone_number

  view :webhook_tmp do
    field :rdv_solidarites_lieu_id, name: :id
  end
end

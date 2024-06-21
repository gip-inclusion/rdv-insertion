class CreateOrientationTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :orientation_types do |t|
      t.string :casf_category
      t.string :name
      t.references :department, foreign_key: true

      t.timestamps
    end

    OrientationType.create(name: "Sociale", casf_category: "social")
    OrientationType.create(name: "Professionnelle", casf_category: "pro")
    OrientationType.create(name: "Socio-professionnelle", casf_category: "socio_pro")
  end
end

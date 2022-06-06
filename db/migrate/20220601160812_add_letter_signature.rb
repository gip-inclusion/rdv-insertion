class AddLetterSignature < ActiveRecord::Migration[7.0]
  def change
    add_column :configurations, :signature_lines, :string, array: true

    up_only do
      Organisation.all.each do |organisation|
        next if organisation.responsible.blank?

        organisation.configurations.each do |configuration|
          configuration.signature_lines =
            ["Pour le Président du Conseil départemental et par délégation,",
             "#{organisation.responsible.full_name}, #{organisation.responsible.role}"]
          configuration.save!
        end
      end
    end
  end
end

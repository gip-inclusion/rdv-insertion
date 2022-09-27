class AddAttributesToConvocations < ActiveRecord::Migration[7.0]
  def change
    add_column :convocations, :format, :integer
    add_reference :convocations, :rdv, foreign_key: true
    up_only do
      # linking to rdvs
      Convocation.find_each do |c|
        if c.applicant.rdvs.empty?
          # No need to keep such convocations
          c.destroy!
        else
          c.update!(rdv_id: c.applicant.rdvs.first.id)
        end
      end
    end
  end
end

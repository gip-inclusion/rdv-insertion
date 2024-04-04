class CreateRdvContexts < ActiveRecord::Migration[6.1]
  def change # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    create_table :rdv_contexts do |t|
      t.integer :context
      t.integer :status
      t.references :applicant, null: false, foreign_key: true

      t.timestamps
    end

    create_join_table :rdvs, :rdv_contexts do |t|
      t.index([:rdv_id, :rdv_context_id], unique: true)
    end

    add_reference :invitations, :rdv_context, foreign_key: true

    add_index "rdv_contexts", ["context"]
    add_index "rdv_contexts", ["status"]

    up_only do
      Applicant.find_each do |applicant|
        next if applicant.not_invited?

        rdv_context = FollowUp.new(applicant: applicant, context: "rsa_orientation")
        rdv_context.save!

        rdv_context.rdvs = applicant.rdvs
        rdv_context.invitations = applicant.invitations

        rdv_context.save!
      end
    end
  end
end

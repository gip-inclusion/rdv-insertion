class CreateOrganisationsInvitationsJoinTable < ActiveRecord::Migration[6.1]
  def up
    add_column :invitations, :context, :string
    add_column :invitations, :rescue_phone_number, :string

    create_join_table :organisations, :invitations do |t|
      t.index(
        [:organisation_id, :invitation_id],
        unique: true,
        name: "index_invitations_orgas_on_orga_id_and_invitation_id"
      )
    end

    add_reference :invitations, :department, foreign_key: true

    Invitation.all.find_each do |invitation|
      organisation = Organisation.find(invitation.organisation_id)
      invitation.update!(
        rescue_phone_number: organisation&.phone_number,
        context: "RSA orientation",
        organisation_ids: [invitation.organisation_id],
        department_id: organisation.department_id
      )
    end

    remove_reference :invitations, :organisation, foreign_key: true
  end

  def down
    add_reference :invitations, :organisation, foreign_key: true

    Invitation.all.find_each do |invitation|
      invitation.update!(organisation_id: invitation.organisation_ids.first)
    end

    remove_reference :invitations, :department, foreign_key: true

    drop_table :invitations_organisations

    remove_column :invitations, :context
    remove_column :invitations, :rescue_phone_number
  end
end

class FillNullUsersOrganisationsCreatedAt < ActiveRecord::Migration[7.0]
  def change
    UsersOrganisation.includes(:user).where(created_at: nil).find_each do |users_organisation|
      users_organisation.update! created_at: users_organisation.user.created_at
    end
  end
end

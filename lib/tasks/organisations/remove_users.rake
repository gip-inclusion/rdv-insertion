namespace :users do
  desc <<-DESC
    https://github.com/gip-inclusion/rdv-insertion/issues/2515
    
    bundle exec rails organisations:remove_users
  DESC

  task remove_from_target_organisations: :environment do
    UsersOrganisation
      .where(organisation: [83,84,85])
      .where("users_organisations.created_at < ?", "2024-01-01")
      .includes(:user, organisation: :agents)
      .find_each do |user_org|
      user_org.organisation.agents.take.with_rdv_solidarites_session do
        Users::RemoveFromOrganisation.call(
          user: user_org.user,
          organisation: user_org.organisation
        )
      end
    end
  end
end
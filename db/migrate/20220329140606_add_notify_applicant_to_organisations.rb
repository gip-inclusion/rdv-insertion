class AddNotifyApplicantToOrganisations < ActiveRecord::Migration[6.1]
  def up
    add_column :organisations, :notify_applicant, :boolean, default: false

    Organisation.find_each do |organisation|
      organisation.update!(notify_applicant: true) if organisation.configurations.first.notify_applicant?
    end

    remove_column :configurations, :notify_applicant
  end

  def down
    add_column :configurations, :notify_applicant, :boolean, default: false

    Configuration.find_each do |configuration|
      configuration.update!(notify_applicant: true) if configuration.organisations.first.notify_applicant?
    end

    remove_column :organisations, :notify_applicant
  end
end

class ChangeOrganisations < ActiveRecord::Migration[6.1]
  def up
    Organisation.find_each do |organisation|
      organisation.name = "Conseil départemental - #{organisation.department.name}"
      organisation.save!
    end

    remove_column :organisations, :number
    remove_column :organisations, :capital
    remove_column :organisations, :region
  end

  # rubocop:disable Metrics/AbcSize
  def down
    add_column :organisations, :number, :string
    add_column :organisations, :capital, :string
    add_column :organisations, :region, :string

    Organisation.find_each do |organisation|
      organisation.name = organisation.department.name
      organisation.number = organisation.department.number
      organisation.capital = organisation.department.capital
      organisation.region = organisation.department.region
      organisation.save!
    end
  end
  # rubocop:enable Metrics/AbcSize
end

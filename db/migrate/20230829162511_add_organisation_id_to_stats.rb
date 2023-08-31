class AddOrganisationIdToStats < ActiveRecord::Migration[7.0]
  def up # rubocop:disable Metrics/AbcSize
    add_reference :stats, :statable, polymorphic: true, index: true

    Stat.find_each do |stat|
      stat.statable_type = stat.department_number.present? ? "Department" : "Organisation"
      if stat.department_number.present? && stat.department_number != "all"
        department = Department.find_by(number: stat.department_number)
        stat.statable_id = department.id
      elsif stat.department_number != "all" && Stat.column_names.include?("organisation_id")
        stat.statable_id = stat.organisation_id
      end
      stat.save!
    end

    initialize_stats_for_organisations if Stat.where(statable_type: "Organisation").empty?

    remove_column :stats, :department_number
    remove_column :stats, :organisation_id if Stat.column_names.include?("organisation_id")
  end

  def down
    add_column :stats, :department_number, :string
    add_column :stats, :organisation_id, :bigint

    Stat.find_each do |stat|
      next unless stat.statable_type == "Department"

      if stat.statable_id.nil?
        stat.department_number = "all"
      else
        department = Department.find(stat.statable_id)
        stat.department_number = department.number
      end
      stat.save!
    end

    remove_reference :stats, :statable, polymorphic: true
  end

  def initialize_stats_for_organisations
    Organisation.find_each do |organisation|
      date = organisation.created_at
      while date < 1.month.ago
        Stats::MonthlyStats::UpsertStatJob.perform_async("Organisation", organisation.id, date)
        date += 1.month
      end
    end
  end
end

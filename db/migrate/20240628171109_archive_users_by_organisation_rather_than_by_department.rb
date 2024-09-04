class ArchiveUsersByOrganisationRatherThanByDepartment < ActiveRecord::Migration[7.1]
  def up
    add_reference :archives, :organisation, foreign_key: true
    migrate_current_archives_to_organisations
    change_column_null :archives, :organisation_id, false
    remove_column :archives, :department_id
  end

  def down
    add_reference :archives, :department, foreign_key: true
    migrate_current_archives_to_departments
    change_column_null :archives, :department_id, false
    remove_column :archives, :organisation_id
  end

  # rubocop:disable Metrics/AbcSize
  def migrate_current_archives_to_organisations
    # we do that to avoid the archive created in the loop to be processed by the find_each
    Archive.find_each do |archive|
      user = archive.user
      department = Department.find(archive.department_id)
      organisations_where_user_should_be_archived = department.organisations & user.organisations
      organisations_where_user_should_be_archived.each do |organisation|
        Sentry.set_extras(archive_id: archive.id, user_id: user.id, organisation_id: organisation.id)
        archive = Archive.new(user_id: user.id, organisation_id: organisation.id, department_id: department.id,
                              archiving_reason: archive.archiving_reason, created_at: archive.created_at)

        # invitations are already invalidated
        archive.skip_after_create = true
        archive.save!
      end
      archive.destroy!
    end
  end
  # rubocop:enable Metrics/AbcSize

  def migrate_current_archives_to_departments
    Archive.find_each do |archive|
      organisation = Organisation.find(archive.organisation_id)
      if Archive.find_by(user_id: archive.user_id, department_id: organisation.department_id).present?
        archive.destroy!
      else
        archive.update!(department_id: organisation.department_id)
      end
    end
  end
end

class UserArchivedStatus
  def initialize(user, organisations)
    @user = user
    @organisations = organisations
  end

  def archived?
    intersection_of_organisations.count == user_archives_in_organisations.count
  end

  private

  def intersection_of_organisations
    @intersection_of_organisations ||= @user.organisations & @organisations
  end

  def user_archives_in_organisations
    @user_archives_in_organisations ||= @user.archives.select do |archive|
      @organisations.map(&:id).include?(archive.organisation_id)
    end
  end
end

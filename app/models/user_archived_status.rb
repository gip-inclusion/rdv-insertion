class UserArchivedStatus
  def initialize(user, organisations)
    @user = user
    @organisations = organisations
  end

  def archived?
    relevant_organisations.count == user_archives_in_organisations.count
  end

  def banner_content
    return unless archived?

    {
      title: "Dossier archivé",
      description: archive_description,
      persist: true
    }
  end

  private

  attr_reader :user, :organisations

  def relevant_organisations
    @relevant_organisations ||= user.organisations & organisations
  end

  def user_archives_in_organisations
    @user_archives_in_organisations ||= user.archives.where(organisation: relevant_organisations)
  end

  def archived_organisations
    @archived_organisations ||= user.archives.map(&:organisation)
  end

  def archive_description
    names = archived_organisations.map(&:name).join(", ")
    wording = archived_organisations.size > 1 ? "les organisations" : "l'organisation"
    "Ce bénéficiaire est archivé sur #{wording} #{names}"
  end
end

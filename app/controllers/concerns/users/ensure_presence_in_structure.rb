module Users::EnsurePresenceInStructure
  extend ActiveSupport::Concern

  private

  def ensure_user_presence_in_structure
    return if @user.present?

    flash[:error] = "Aucun utilisateur trouvé avec cet identifiant dans votre structure. L'utilisateur a peut-être été archivé ou supprimé de votre structure."
    redirect_to structure_users_path
  end
end

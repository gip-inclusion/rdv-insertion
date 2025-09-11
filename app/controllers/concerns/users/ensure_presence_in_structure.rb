module Users::EnsurePresenceInStructure
  extend ActiveSupport::Concern

  private

  def ensure_user_presence_in_structure
    return if @user.present?

    flash[:error] = "Aucun usager trouvé avec cet identifiant dans votre structure." \
                    " L'usager a peut-être été archivé ou supprimé de votre structure."

    if turbo_frame_request?
      turbo_stream_redirect(structure_users_path)
    else
      redirect_to structure_users_path
    end
  end
end

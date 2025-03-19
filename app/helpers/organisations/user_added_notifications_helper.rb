module Organisations
  module UserAddedNotificationsHelper
    def user_added_notification_subject
      "[RDV-Insertion] Un usager a été ajouté à votre organisation"
    end

    def user_added_notification_content(user, organisation)
      "L'usager #{user} a été ajouté à votre organisation #{organisation.name}.\nVous pouvez consulter son profil" \
      " à l'adresse suivante :\n #{organisation_user_url(
        id: user.id, organisation_id: organisation.id, host: ENV['HOST']
      )}"
    end
  end
end

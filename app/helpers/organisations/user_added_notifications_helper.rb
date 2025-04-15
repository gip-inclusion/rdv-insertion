module Organisations
  module UserAddedNotificationsHelper
    def user_added_notification_subject
      "[RDV-Insertion] Un usager a été ajouté à votre organisation"
    end

    def user_added_notification_content(source:, user:, organisation:)
      if source.to_s == "orientation"
        user_added_from_orientation_notification_content(user, organisation)
      else
        user_added_from_show_page_notification_content(user, organisation)
      end
    end

    def user_added_from_show_page_notification_content(user, organisation)
      "L'usager #{user} a été ajouté à votre organisation #{organisation.name}.\nVous pouvez consulter son profil" \
      " à l'adresse suivante :\n #{organisation_user_url(
        id: user.id, organisation_id: organisation.id, host: ENV['HOST']
      )}"
    end

    def user_added_from_orientation_notification_content(user, organisation)
      "L'usager #{user} a été ajouté à votre organisation #{organisation.name}.\nVous pouvez consulter son historique" \
        " d'accompagnement ainsi que les éventuels documents de parcours téléchargés (diagnostic, contrat) " \
        "sur le lien suivant :\n #{organisation_user_parcours_url(
          user_id: user.id, organisation_id: organisation.id, host: ENV['HOST']
        )}"
    end
  end
end

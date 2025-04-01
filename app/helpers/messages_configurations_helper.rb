module MessagesConfigurationsHelper
  def letter_sender_name_tooltip_content
    safe_join(
      [
        "Dans les courriers d'invitation, permet de personnaliser la phrase :",
        tag.br,
        tag.i("Pour faciliter votre prise de rendez-vous, le Conseil départemental a mis en place."),
        tag.br,
        tag.br,
        "Si cette option est définie, la valeur renseignée remplacera ",
        tag.i("le Conseil départemental"),
        " dans cette phrase."
      ]
    )
  end

  def help_address_tooltip_content
    safe_join(
      [
        "Les courriers d'invitation se terminent par la phrase suivante :",
        tag.br,
        tag.i(
          "Si vous rencontrez une difficulté pour accéder à internet, " \
          "veuillez téléphoner dès réception de ce courrier au XXXXXXXX."
        ),
        tag.br,
        tag.br,
        "Si cette option est renseignée, la phrase se poursuivra de la manière suivante : " \
        "veuillez téléphoner dès réception de ce courrier au XXXXXXXXXX ou vous rendre ",
        tag.i("texte défini avec cette option"),
        "."
      ]
    )
  end

  def sms_sender_name_tooltip_content
    safe_join(
      [
        "Par défaut, le nom de l'expéditeur des SMS reçus par les usagers est : Dept17 (le numéro change en fonction " \
        "du département). Vous pouvez modifier l'expéditeur affiché ici. Attention, le nom ne doit pas dépasser " \
        "11 caractères et ne comporter aucun espace.",
        tag.br,
        tag.br,
        tag.b("Nous vous recommandons de ne pas modifier cette option.")
      ]
    )
  end
end

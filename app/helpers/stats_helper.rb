# rubocop:disable Metrics/ModuleLength
module StatsHelper
  def options_for_department_select(departments)
    departments.map { |d| ["#{d.number} - #{d.name}", d.id] }
               .unshift(["Tous les départements", "0"])
  end

  def options_for_organisation_select(department)
    default_option = [["Sélection", [["Toutes les organisations", "0"]]]]
    grouped_organisations = department.organisations.reject { |o| disable_stats_for_organisation?(o) }
                                      .group_by(&:organisation_type)
                                      .map do |type, orgs|
      [
        type.humanize,
        orgs.map { |o| [o.name.to_s, o.id] }
      ]
    end
    default_option + grouped_organisations
  end

  def sanitize_monthly_data(stat)
    exclude_starting_zeros(exclude_current_month(stat))
  end

  def exclude_starting_zeros(stat)
    return unless stat

    stat.to_a.drop_while { |_, value| value.to_i.zero? }.to_h
  end

  def exclude_current_month(stat)
    exclude_months(stat, [Time.zone.now.strftime("%m/%Y")])
  end

  def exclude_current_and_previous_month(stat)
    exclude_months(stat, [1.month.ago.strftime("%m/%Y"), Time.zone.now.strftime("%m/%Y")])
  end

  def exclude_months(stat, months)
    stat&.delete_if { |key, _value| months.include?(key) }
  end

  private

  def organisation_ids_where_stats_disabled
    ENV.fetch("ORGANISATION_IDS_WHERE_STATS_DISABLED", "").split(",")
  end

  def disable_stats_for_organisation?(organisation)
    organisation_ids_where_stats_disabled.include?(organisation.id.to_s)
  end

  def users_count_tooltip
    tooltip(
      content: "Il s'agit du nombre d'usagers qui ont été créés sur l'application rdv-insertion. " \
               "NB : techniquement, les agents sont créés à partir de l'interface RDV Solidarités."
    )
  end

  def rdvs_count_tooltip
    tooltip(
      content: "Il s'agit du nombre de rendez-vous qui ont été positionnés sur l'application rdv-insertion. " \
               "Notez que les rendez-vous peuvent avoir été pris directement par les usagers ou bien positionnés " \
               "par les professionnels. De même, ces rendez-vous ont pu être honorés ou pas, ou bien annulés à " \
               "l'initiative de l'usager ou du service. NB : techniquement, les rendez-vous sont créés à partir " \
               "de l'interface RDV Solidarités."
    )
  end

  def invitations_count_tooltip
    tooltip(
      content: "Il s'agit du nombre d'invitations à prendre rendez-vous envoyées depuis rdv-insertion " \
               "et ce, quel que soit le support (invitation mail, SMS, courrier). Ce graphique ne s'applique " \
               "donc pas aux organisations qui n'invitent pas les usagers et procèdent uniquement à des convocations."
    )
  end

  def average_time_between_invitation_and_rdv_tooltip
    tooltip(
      content: "Il s'agit du délai entre le moment où le professionnel génère l'invitation mail, sms ou courrier " \
               "à prendre rendez-vous, d'une part, et le moment où le rendez-vous est effectivement pris " \
               "(que ce soit en autonomie à l'initiative de l'usager ou bien à l'initiative du professionnel)."
    )
  end

  def rate_of_no_show_for_invitations_tooltip
    tooltip(
      content: "Il s'agit du taux d'absentéisme des rendez-vous qui ont été pris en autonomie par les usagers " \
               "(choix du créneaux et, le cas échéant, du lieu) grâce à une invitation à prendre rendez-vous."
    )
  end

  def rate_of_no_show_for_convocations_tooltip
    tooltip(
      content: "Il s'agit du taux d'absentéisme des rendez-vous qui ont été positionnés directement par les " \
               "professionnels (convocation) depuis l'interface RDV Solidarités."
    )
  end

  def rate_of_no_show_tooltip
    tooltip(
      content: "Il s'agit du taux agrégé d'absentéisme, peu importe la nature de la prise de rendez-vous " \
               "(par l'usager directement en autonomie après invitation à prendre rendez-vous ou bien par " \
               "le professionnel via une convocation adressée à l'usager)."
    )
  end

  def rate_of_users_oriented_in_less_than_45_days_tooltip
    tooltip(
      content: "Il s'agit du pourcentage d'usagers qui valident la condition suivante : rendez-vous d'orientation " \
               "honoré au plus tard 45 jours après l'ouverture du suivi de la catégorie RSA orientation sur " \
               "rdv-insertion. Ce délai de 6 semaines fait référence au délai prévu par le décret n° 2024-1244 " \
               "du 30 décembre 2024 relatif aux délais d'orientation et d'accompagnement des demandeurs d'emploi " \
               "qui fixe à six semaines le délai au terme duquel le président du conseil départemental doit orienter " \
               "le bénéficiaire du revenu de solidarité active vers un organisme référent. NB : comme borne " \
               "temporelle de départ, nous nous basons sur l'ouverture du suivi de la catégorie RSA orientation et " \
               "non sur l'ouverture des droits du bénéficiaire car c'est une donnée qui est très rarement disponible " \
               "et ajoutée sur rdv-insertion."
    )
  end

  def rate_of_users_accompanied_in_less_than_30_days_tooltip
    tooltip(
      content: "Il s'agit du pourcentage d'usagers qui valident la condition suivante : rendez-vous d'accompagnement " \
               "honoré au plus tard 30 jours après l'ouverture du suivi de la catégorie RSA accompagnement ou bien, " \
               "pour les usagers qui avaient déjà un rendez-vous d'orientation sur notre outil, rendez-vous " \
               "d'accompagnement honoré au plus tard 30 jours après le rendez-vous d'orientation précédemment honoré." \
               " Ce délai de 4 semaines fait référence au délai prévu par le décret n° 2024-1244 " \
               "du 30 décembre 2024 relatif aux délais d'orientation et d'accompagnement des demandeurs d'emploi " \
               "qui fixe à 4 semaines le délai durant lequel le bénéficiaire doit signer son contrat d'engagement."
    )
  end

  def rate_of_autonomous_users_tooltip
    tooltip(
      content: "Il s'agit du pourcentage d'usagers ayant été invités à prendre rendez-vous en autonomie et s'étant " \
               "par la suite positionnés en autonomie sur le choix d'un rendez-vous. Plus de la moitié des usagers " \
               "se positionnent ainsi sans recourir à l'aide du service, en totale autonomie. Notez qu'une forme " \
               "d'autonomie peut exister chez les autres bénéficiaires qui, pour diverses raisons (crainte d'un " \
               "fishing, difficultés illectroniques, etc.), préfèrent appeler le numéro qui apparait dans le message " \
               "d'invitation et sont alors accompagnés au téléphone dans la prise de rendez-vous par un professionnel" \
               " qui prend rendez-vous en leur nom."
    )
  end

  def rate_of_users_oriented_tooltip
    tooltip(
      content: "Il s'agit du taux d'usagers qui ont effectivement eu un rendez-vous d'orientation honoré parmi " \
               "tous ceux pour qui un suivi RSA orientation ouvert."
    )
  end

  def users_with_rdv_tooltip
    tooltip(
      content: "Il s’agit du nombre d’usagers uniques ayant un rendez-vous honoré ou un rendez-vous " \
               "à venir dans le mois concerné."
    )
  end

  def agents_count_tooltip
    tooltip(
      content: "Il s'agit du nombre d'agents créés sur rdv-insertion qui peuvent appartenir à des organisations " \
               "des conseils départementaux, à des agences France Travail, à des délégataires RSA ou bien à des " \
               "structures d'insertion par l'activité économique (SIAE). Notez que le nombre de territoires " \
               "départementaux affiché n'équivaut pas au nombre de conseils départementaux utilisateurs de " \
               "rdv-insertion. En effet, un territoire est comptabilisé dès lors qu'une seule organisation est " \
               "devenue utilisatrice sur le territoire (ex : une SIAE) et ce, même si ledit territoire n'utilise " \
               "pas rdv-insertion pour la gestion des rendez-vous RSA."
    )
  end
end
# rubocop:enable Metrics/ModuleLength

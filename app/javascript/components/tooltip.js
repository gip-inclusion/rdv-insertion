import tippy from "tippy.js";

const initToolTip = () => {
  tippy("#js-action-required-tooltip", {
    content(reference) {
      const { numberOfDaysBeforeActionRequired } = reference.dataset;
      return (
        "Une intervention est nécessaire quand: " +
        `<ul><li>L'invitation a été envoyée depuis + de ${numberOfDaysBeforeActionRequired} jours sans réponse</li>` +
        "<li>Le RDV a été annulé par l'un des partis ou l'allocataire ne s'est pas présenté au RDV</li>" +
        "<li>L'issue du RDV n'a pas été renseignée sur RDV-Solidarités</li></ul>"
      );
    },
    allowHTML: true,
  });

  tippy("#js-csv-export-tooltip", {
    content:
      "Les bénéficiaires seront exportés en fonction du contexte et des éventuels filtres sélectionnés",
    placement: "bottom",
  });

  tippy("#js-rdv-cancelled-by-user-tooltip", {
    content: "Nombre de rendez-vous manqués ou annulés par l'allocataire",
  });

  tippy("#js-organisation-details-tooltip", {
    content:
      "Les modifications du nom, de l'email et du téléphone seront répercutées sur RDV-Solidarités",
    placement: "bottom",
  });

  tippy("#js-independent_from_cd-attribute-tooltip", {
    content:
      "Si l'organisation n'est pas une émanation du CD, certaines phrases des invitations sont différentes. " +
      "Pour plus de détails, demandez à l'équipe de rdv-insertion.",
  });

  tippy("#js-slug-attribute-tooltip", {
    content:
      "Si l'assignation des allocataires à l'organisation se fait via une colonne du fichier d'import " +
      "des allocataires, les cases de cette colonne devront faire référence à la valeur définie ici.",
  });

  tippy("#js-direction_names-attribute-tooltip", {
    content:
      "Si aucun en-tête n'est défini, c'est le nom de l'organisation qui sera utilisé en haut à gauche du courrier.",
  });

  tippy("#js-sender_city-attribute-tooltip", {
    content: "Si aucune ville n'est définie, c'est la préfecture du département qui sera utilisée.",
  });

  tippy("#js-letter_sender_name-attribute-tooltip", {
    content() {
      return (
        "Dans les courriers d'invitation, permet de personnaliser la phrase :<br/>" +
        "<i>Pour faciliter votre prise de rendez-vous, le Conseil départemental a mis en place.<br/><br/></i>" +
        "Si cette option est définie, la valeur renseignée remplacera <i>le Conseil départemental</i> dans cette phrase."
      );
    },
    allowHTML: true,
  });

  tippy("#js-display_department_logo-attribute-tooltip", {
    content:
      "Si le logo de l'organisation n'est pas défini, le logo du département sera utilisé quoi qu'il arrive.",
  });

  tippy("#js-help_address-attribute-tooltip", {
    content() {
      return (
        "Les courriers d'invitation se terminent par la phrase suivante :<br/>" +
        "<i>Si vous rencontrez une difficulté pour accéder à internet, veuillez téléphoner dès réception de ce courrier au XXXXXXXX.<br/><br/></i>" +
        "Si cette option est renseignée, la phrase se poursuivra de la manière suivante : veuillez téléphoner dès réception de ce courrier au XXXXXXXXXX ou vous rendre <i>texte défini avec cette option</i>."
      );
    },
    allowHTML: true,
  });

  tippy("#js-sms_sender_name-attribute-tooltip", {
    content() {
      return (
        "Par défaut, le nom de l'expéditeur des SMS reçus par les usagers est : Dept17 (le numéro change en fonction " +
        "du département). Vous pouvez modifier l'expéditeur affiché ici. Attention, le nom ne doit pas dépasser " +
        "11 caractères et ne comporter aucun espace.<br/><br/>" +
        "<b>Nous vous recommandons de ne pas modifier cette option.</b>"
      );
    },
    allowHTML: true,
  });
};

export default initToolTip;

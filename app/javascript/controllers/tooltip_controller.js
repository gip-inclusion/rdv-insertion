import { Controller } from "@hotwired/stimulus";
import tippy from "tippy.js";

export default class extends Controller {
  actionRequired() {
    tippy(this.element, {
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
  }

  csvExport() {
    tippy(this.element, {
      content:
        "Les bénéficiaires seront exportés en fonction du contexte et des éventuels filtres sélectionnés",
      placement: "bottom",
    });
  }

  disabledConvocationButton() {
    tippy(this.element, {
      content:
        "Aucun motif avec la mention 'convocation' n'a été trouvé sur RDV-Solidarités pour cette catégorie.<br/>" +
        "Contactez-nous à data.insertion@beta.gouv.fr pour en savoir plus sur la fonctionnalité de convocation.",
      allowHTML: true,
    });
  }

  organisationDetails() {
    tippy(this.element, {
      content:
        "Les modifications du nom, de l'email et du téléphone seront répercutées sur RDV-Solidarités",
      placement: "bottom",
    });
  }

  independentFromCdAttribute() {
    tippy(this.element, {
      content:
        "Si l'organisation n'est pas une émanation du CD, certaines phrases des invitations sont différentes. " +
        "Pour plus de détails, demandez à l'équipe de rdv-insertion.",
    });
  }

  slugAttribute() {
    tippy(this.element, {
      content:
        "Si l'assignation des allocataires à l'organisation se fait via une colonne du fichier d'import " +
        "des allocataires, les cases de cette colonne devront faire référence à la valeur définie ici.",
    });
  }

  logoFilenameAttribute() {
    tippy(this.element, {
      content: "Renseigner le nom du logo sans l'extension du fichier (.png, .svg, .jpg)",
    });
  }

  senderCityAttribute() {
    tippy(this.element, {
      content:
        "Si aucune ville n'est définie, c'est la préfecture du département qui sera utilisée.",
    });
  }

  directionNamesAttribute() {
    tippy(this.element, {
      content:
        "Si aucun en-tête n'est défini, c'est le nom de l'organisation qui sera utilisé en haut à gauche du courrier.",
    });
  }

  letterSenderNameAttribute() {
    tippy(this.element, {
      content() {
        return (
          "Dans les courriers d'invitation, permet de personnaliser la phrase :<br/>" +
          "<i>Pour faciliter votre prise de rendez-vous, le Conseil départemental a mis en place.<br/><br/></i>" +
          "Si cette option est définie, la valeur renseignée remplacera <i>le Conseil départemental</i> dans cette phrase."
        );
      },
      allowHTML: true,
    });
  }

  displayDepartmentLogoAttribute() {
    tippy(this.element, {
      content:
        "Si le logo de l'organisation n'est pas défini, le logo du département sera utilisé quoi qu'il arrive.",
    });
  }

  departmentInternalIdAttribute() {
    tippy(this.element, {
      content: "ID dans l'éditeur logiciel (IODAS, SOLIS...) ou dans le SI du département",
    });
  }

  closeRdvContextButton() {
    tippy(this.element, {
      content:
        "Le statut du bénéficiaire dans ce contexte passera en «Dossier traité» et ses invitations seront désactivées.",
      placement: "bottom",
    });
  }

  reopenRdvContextButton() {
    tippy(this.element, {
      content: "Le bénéficiaire pourra de nouveau être invité et suivi dans ce contexte",
      placement: "bottom",
    });
  }

  helpAddressAttribute() {
    tippy(this.element, {
      content() {
        return (
          "Les courriers d'invitation se terminent par la phrase suivante :<br/>" +
          "<i>Si vous rencontrez une difficulté pour accéder à internet, veuillez téléphoner dès réception de ce courrier au XXXXXXXX.<br/><br/></i>" +
          "Si cette option est renseignée, la phrase se poursuivra de la manière suivante : veuillez téléphoner dès réception de ce courrier au XXXXXXXXXX ou vous rendre <i>texte défini avec cette option</i>."
        );
      },
      allowHTML: true,
    });
  }

  smsSenderNameAttribute() {
    tippy(this.element, {
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
  }

  archivingDisabled() {
    // the button is in a wrapper because we cannot set a tooltip on a disabled element
    const archivingButton = document.getElementById("archive-button");
    if (archivingButton.disabled) {
      tippy(this.element, {
        content:
          "Vous devez appartenir à toutes les organisations auxquelles appartient le bénéficiaire au sein de votre département pour pouvoir l'archiver",
      });
    }
  }
}

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

  tippy("#js-disabled-convocation-button", {
    content:
      "Aucun motif avec la mention 'convocation' n'a été trouvé sur RDV-Solidarités pour cette catégorie.<br/>" +
      "Contactez-nous à data.insertion@beta.gouv.fr pour en savoir plus sur la fonctionnalité de convocation.",
    allowHTML: true,
  });
};

export default initToolTip;

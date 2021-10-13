import tippy from "tippy.js";

const initToolTip = () => {
  tippy("#js-action-required-tooltip", {
    content:
      "Une intervention est nécessaire quand: " +
      "<ul><li>L'invitation a été envoyée depuis + de 3 jours sans réponse</li>" +
      "<li>Le RDV a été annulé par l'un des partis ou le bRSA ne s'est pas présenté au RDV</li>" +
      "<li>L'utilisateur n'a pas été invité</li>" +
      "<li>L'issue du RDV n'a pas été renseignée sur RDV-Solidarités</li></ul>",
    allowHTML: true,
  });
};

export default initToolTip;

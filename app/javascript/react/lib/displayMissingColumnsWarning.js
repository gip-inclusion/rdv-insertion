import safeSwal from "../../lib/safeSwal";

const displayMissingColumnsWarning = (missingColumnNames) => {
  safeSwal({
    title: "Le fichier chargé ne correspond pas au format attendu",
    html: `Veuillez vérifier que les colonnes suivantes sont présentes et correctement nommées&nbsp;:
      <br/>
      <strong>${missingColumnNames.join("<br />")}</strong>`,
    icon: "error",
  });
};

export default displayMissingColumnsWarning;

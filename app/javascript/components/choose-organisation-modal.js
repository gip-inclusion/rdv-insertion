import safeSwal from "../lib/safeSwal";

const chooseOrganisationModal = async (organisations, title, text) => {
  const organisationsObject = {};
  organisations.forEach((o) => {
    organisationsObject[o.id] = o.name;
  });

  const result = await safeSwal({
    title,
    html: text,
    icon: "warning",
    input: "select",
    confirmButtonText: "Sélectionner",
    inputOptions: organisationsObject,
  });
  if (!result.value) return null;

  return organisations.find((o) => o.id.toString() === result.value.toString());
};

export default chooseOrganisationModal;

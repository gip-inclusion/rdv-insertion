import Swal from "sweetalert2";

const chooseOrganisationModal = async (organisations, title, text) => {
  const organisationsObject = {};
  organisations.forEach((o) => {
    organisationsObject[o.id] = o.name;
  });

  const result = await Swal.fire({
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

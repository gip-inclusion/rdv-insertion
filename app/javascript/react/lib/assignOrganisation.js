import Swal from "sweetalert2";
import retrieveGeolocatedOrganisations from "../actions/retrieveGeolocatedOrganisations";

const chooseOrganisationModal = async (organisations, address, errors = []) => {
  const title =
    errors && errors.length > 0
      ? errors.join(", ")
      : "Plusieurs organisations sont possibles pour cette addresse.";

  const text = `Veuillez choisir une organisation pour l'adresse: <strong>${address}</strong>`;

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

  return organisations.find((o) => o.id.toString() === result.value.toString());
};

const assignOrganisation = async (applicant) => {
  const result = await retrieveGeolocatedOrganisations(
    applicant.departmentNumber,
    applicant.fullAddress
  );
  if (result.success) {
    if (result.organisations_attributed_to_sector.length === 1) {
      [applicant.organisation] = result.organisations_attributed_to_sector;
    } else {
      applicant.organisation = await chooseOrganisationModal(
        result.organisations_attributed_to_sector.length > 1
          ? result.organisations_attributed_to_sector
          : result.organisations,
        applicant.fullAddress
      );
    }
  } else {
    applicant.organisation = await chooseOrganisationModal(
      result.organisations,
      applicant.fullAddress,
      result.errors
    );
  }
};

export default assignOrganisation;

import chooseOrganisationModal from "../components/choose-organisation-modal";
import retrieveGeolocatedOrganisations from "../actions/retrieveGeolocatedOrganisations";

const retrieveRelevantOrganisation = async (
  departmentNumber,
  userFullAddress,
  options = { raiseError: true }
) => {
  return retrieveThroughGeolocalisation(departmentNumber, userFullAddress, options);
};

const retrieveThroughGeolocalisation = async (
  departmentNumber,
  userFullAddress,
  options = { raiseError: true }
) => {
  const result = await retrieveGeolocatedOrganisations(departmentNumber, userFullAddress);

  if (result.success && result.geolocated_organisations.length === 1) {
    return result.geolocated_organisations[0];
  }

  if (options.raiseError === false) {
    return null;
  }

  let modalTitle;

  if (result.errors && result.errors.length > 0) {
    modalTitle = result.errors.join(", ");
  } else {
    modalTitle = "Il n'y a pas d'organisation spécifique à ce secteur.";
  }

  const modalText = `Veuillez choisir une organisation pour l'adresse: <strong>${userFullAddress}</strong>`;

  return chooseOrganisationModal(
    result.geolocated_organisations && result.geolocated_organisations.length > 1
      ? result.geolocated_organisations
      : result.department_organisations,
    modalTitle,
    modalText
  );
};

export default retrieveRelevantOrganisation;

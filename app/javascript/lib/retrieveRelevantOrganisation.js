import chooseOrganisationModal from "../components/choose-organisation-modal";
import retrieveGeolocatedOrganisations from "../react/actions/retrieveGeolocatedOrganisations";
import searchOrganisations from "../react/actions/searchOrganisations";

const retrieveRelevantOrganisation = async (
  departmentNumber,
  organisationSearchTerms,
  applicantFullAddress,
  options = { raiseError: true }
) => {
  if (organisationSearchTerms) {
    return retrieveThroughSearchTerms(departmentNumber, organisationSearchTerms, options);
  }

  return retrieveThroughGeolocalisation(departmentNumber, applicantFullAddress, options);
};

const retrieveThroughSearchTerms = async (departmentNumber, organisationSearchTerms, options = { raiseError: true }) => {
  const result = await searchOrganisations(departmentNumber, organisationSearchTerms);
  if (result.success && result.matching_organisations.length === 1) {
    return result.matching_organisations[0];
  }

  if (options.raiseError === false) {
    return null;
  }

  let modalTitle;

  if (result.errors && result.errors.length > 0) {
    modalTitle = result.errors.join(", ");
  } else {
    modalTitle = `Aucune organisation ne correspond à <strong>${organisationSearchTerms}</strong>.`;
  }
  const modalText = "Veuillez choisir une organisation parmi les suivantes:";

  return chooseOrganisationModal(
    result.matching_organisations && result.matching_organisations.length > 1
      ? result.matching_organisations
      : result.department_organisations,
    modalTitle,
    modalText
  );
};

const retrieveThroughGeolocalisation = async (departmentNumber, applicantFullAddress, options = { raiseError: true }) => {
  const result = await retrieveGeolocatedOrganisations(departmentNumber, applicantFullAddress);

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

  const modalText = `Veuillez choisir une organisation pour l'adresse: <strong>${applicantFullAddress}</strong>`;

  return chooseOrganisationModal(
    result.geolocated_organisations && result.geolocated_organisations.length > 1
      ? result.geolocated_organisations
      : result.department_organisations,
    modalTitle,
    modalText
  );
};

export default retrieveRelevantOrganisation;

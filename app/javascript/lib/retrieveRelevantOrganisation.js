import chooseOrganisationModal from "../components/choose-organisation-modal";
import retrieveGeolocatedOrganisations from "../react/actions/retrieveGeolocatedOrganisations";

const retrieveRelevantOrganisation = async (departmentNumber, applicantFullAddress) => {
  const result = await retrieveGeolocatedOrganisations(departmentNumber, applicantFullAddress);

  if (result.success) {
    if (result.geolocated_organisations.length === 1) {
      return result.geolocated_organisations[0];
    }

    return chooseOrganisationModal(
      result.geolocated_organisations.length > 1
        ? result.geolocated_organisations
        : result.department_organisations,
      applicantFullAddress
    );
  }

  return chooseOrganisationModal(
    result.department_organisations,
    applicantFullAddress,
    result.errors
  );
};

export default retrieveRelevantOrganisation;

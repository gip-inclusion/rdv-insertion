import appFetch from "../../lib/appFetch";

const retrieveGeolocatedOrganisations = async (departmentNumber, address) =>
  appFetch(
    `/organisations/geolocated?department_number=${encodeURIComponent(
      departmentNumber
    )}&address=${encodeURIComponent(address)}`
  );

export default retrieveGeolocatedOrganisations;

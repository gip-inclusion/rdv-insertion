import fetchApp from "../../lib/fetchApp";

const retrieveGeolocatedOrganisations = async (departmentNumber, address) =>
  fetchApp(
    `/organisations/geolocated?department_number=${encodeURIComponent(
      departmentNumber
    )}&address=${encodeURIComponent(address)}`,
    {
      parseJson: true,
    }
  );

export default retrieveGeolocatedOrganisations;

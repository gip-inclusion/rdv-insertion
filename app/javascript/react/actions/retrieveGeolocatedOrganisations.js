const retrieveGeolocatedOrganisations = async (departmentNumber, address) => {
  const response = await fetch(
    `/organisations/geolocated?department_number=${encodeURIComponent(
      departmentNumber
    )}&address=${encodeURIComponent(address)}`,
    {
      method: "GET",
      credentials: "same-origin",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content,
      },
    }
  );

  return response.json();
};

export default retrieveGeolocatedOrganisations;

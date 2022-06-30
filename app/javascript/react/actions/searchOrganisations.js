import appFetch from "../../lib/appFetch";

const searchOrganisations = async (departmentNumber, searchTerms) =>
  appFetch(
    `/organisations/search?department_number=${encodeURIComponent(
      departmentNumber
    )}&search_terms=${encodeURIComponent(searchTerms)}`
  );

export default searchOrganisations;

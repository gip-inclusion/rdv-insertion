import fetchApp from "../../lib/fetchApp";

const searchOrganisations = async (departmentNumber, searchTerms) =>
  fetchApp(
    `/organisations/search?department_number=${encodeURIComponent(
      departmentNumber
    )}&search_terms=${encodeURIComponent(searchTerms)}`,
    {
      parseJson: true,
    }
  );

export default searchOrganisations;

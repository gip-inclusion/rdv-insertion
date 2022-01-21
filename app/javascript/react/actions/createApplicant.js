import appFetch from "../../lib/appFetch";

const createApplicant = async (applicant, organisationId) =>
  appFetch(`/organisations/${organisationId}/applicants`, "POST", {
    applicant: applicant.asJson(),
  });

export default createApplicant;

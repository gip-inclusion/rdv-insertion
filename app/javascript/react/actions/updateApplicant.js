import appFetch from "../../lib/appFetch";

const updateApplicant = async (organisationId, applicantId, attributes = {}) =>
  appFetch(`/organisations/${organisationId}/applicants/${applicantId}`, "PATCH", {
    applicant: attributes,
  });

export default updateApplicant;

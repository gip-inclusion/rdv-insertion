import appFetch from "../../lib/appFetch";

const archiveApplicant = async (applicantId, attributes) =>
  appFetch(`/applicants/${applicantId}/archivings`, "POST", attributes);

export default archiveApplicant;

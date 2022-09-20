import appFetch from "../../lib/appFetch";

const unarchiveApplicant = async (applicantId) =>
  appFetch(`/applicants/${applicantId}/archivings`, "DELETE");

export default unarchiveApplicant;

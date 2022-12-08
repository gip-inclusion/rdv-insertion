import appFetch from "../../lib/appFetch";

const assignReferent = async (departmentId, applicantId, referentEmail) =>
  appFetch(`/departments/${departmentId}/referent_assignations`, "POST", {
    referent_assignation: { applicant_id: applicantId, agent_email: referentEmail },
  });

export default assignReferent;

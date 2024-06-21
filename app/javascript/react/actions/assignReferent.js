import appFetch from "../../lib/appFetch";

const assignReferent = async (
  userId,
  referentEmail,
  departmentId,
  organisationId,
  isDepartmentLevel
) => {
  let url;
  if (isDepartmentLevel) {
    url = `/departments/${departmentId}/referent_assignations`;
  } else {
    url = `/organisations/${organisationId}/referent_assignations`;
  }
  return appFetch(url, "POST", {
    referent_assignation: { user_id: userId, agent_email: referentEmail },
  });
}

export default assignReferent;

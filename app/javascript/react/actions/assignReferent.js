import appFetch from "../../lib/appFetch";

const assignReferent = async (
  userId,
  referentEmail
) => {
  const url = `/users/${userId}/referent_assignations`;
  return appFetch(url, "POST", {
    referent_assignation: { user_id: userId, agent_email: referentEmail },
  });
}

export default assignReferent;

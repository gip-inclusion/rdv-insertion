import appFetch from "../../lib/appFetch";

const assignReferent = async (userId, referentEmail) =>
  appFetch("/referent_assignations", "POST", {
    referent_assignation: { user_id: userId, agent_email: referentEmail },
  });

export default assignReferent;

import fetchApp from "../../lib/fetchApp";

const assignReferent = async (
  userId,
  referentEmail
) => {
  const url = `/users/${userId}/referent_assignations`;
  return fetchApp(url, {
    method: "POST",
    body: {
      referent_assignation: { user_id: userId, agent_email: referentEmail },
    },
    parseJson: true,
  });
}

export default assignReferent;

import appFetch from "../../lib/appFetch";

const createUser = async (user, organisationId) =>
  appFetch(`/organisations/${organisationId}/users`, "POST", {
    user: user.asJson(),
  });

export default createUser;

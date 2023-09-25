import appFetch from "../../lib/appFetch";

const updateUser = async (organisationId, userId, attributes = {}) =>
  appFetch(`/organisations/${organisationId}/users/${userId}`, "PATCH", {
    user: attributes,
  });

export default updateUser;

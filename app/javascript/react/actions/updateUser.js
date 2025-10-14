import fetchApp from "../../lib/fetchApp";

const updateUser = async (organisationId, userId, attributes = {}) =>
  fetchApp(`/organisations/${organisationId}/users/${userId}`, {
    method: "PATCH",
    body: {
      user: attributes,
    },
    parseJson: true,
  });

export default updateUser;

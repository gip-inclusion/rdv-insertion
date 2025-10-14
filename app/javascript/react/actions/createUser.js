import fetchApp from "../../lib/fetchApp";

const createUser = async (user, organisationId) =>
  fetchApp(`/organisations/${organisationId}/users`, {
    method: "POST",
    body: {
      user: user.asJson(),
    },
    parseJson: true,
  });

export default createUser;

import safeSwal from "../../lib/safeSwal";
import createUser from "../actions/createUser";

const handleUserCreation = async (user, organisationId, options = { raiseError: true }) => {
  const result = await createUser(user, organisationId);
  if (result.success) {
    user.updateWith(result.user);
  } else if (options.raiseError)
    safeSwal({
      title: "Impossible de créer l'usager",
      text: result.errors[0],
      icon: "error",
    });
  return result;
};

export default handleUserCreation;

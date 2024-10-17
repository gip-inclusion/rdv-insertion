import Swal from "sweetalert2";
import createUser from "../actions/createUser";

const handleUserCreation = async (user, organisationId, options = { raiseError: true }) => {
  const result = await createUser(user, organisationId);
  if (result.success) {
    user.updateWith(result.user);
  } else if (options.raiseError)
    Swal.fire("Impossible de créer l'usager", result.errors[0], "error");
  return result;
};

export default handleUserCreation;

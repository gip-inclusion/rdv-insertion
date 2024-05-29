import Swal from "sweetalert2";
import updateUser from "../actions/updateUser";

const handleUserUpdate = async (organisationId, user, attributes, options = {}) => {
  const result = await updateUser(organisationId, user.id, attributes);
  if (result.success) {
    user.updateWith(result.user, options);
  } else {
    Swal.fire("Impossible de mettre à jour le bénéficiaire'", result.errors[0], "error");
  }
  return result;
};

export default handleUserUpdate;

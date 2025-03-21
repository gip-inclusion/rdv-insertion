import safeSwal from "../../lib/safeSwal";
import updateUser from "../actions/updateUser";

const handleUserUpdate = async (organisationId, user, attributes, options = {}) => {
  const result = await updateUser(organisationId, user.id, attributes);
  if (result.success) {
    user.updateWith(result.user, options);
  } else {
    safeSwal({
      title: "Impossible de mettre à jour le bénéficiaire",
      text: result.errors[0],
      icon: "error",
    });
  }
  return result;
};

export default handleUserUpdate;

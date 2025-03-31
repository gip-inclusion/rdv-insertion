import safeSwal from "../../lib/safeSwal";
import createCarnet from "../actions/createCarnet";

const handleCarnetCreation = async (user) => {
  const result = await createCarnet(user.id, user.department.id);
  if (result.success) {
    user.updateWith(result.user);
  } else {
    safeSwal({
      title: "Impossible de créer le carnet",
      text: result.errors.join("\n"),
      icon: "error",
    });
  }
};

export default handleCarnetCreation;

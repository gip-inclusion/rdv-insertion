import Swal from "sweetalert2";
import createCarnet from "../actions/createCarnet";

const handleCarnetCreation = async (user) => {
  const result = await createCarnet(user.id, user.department.id);
  if (result.success) {
    user.updateWith(result.user);
  } else {
    Swal.fire("Impossible de créer le carnet", result.errors.join("\n"), "error");
  }
};

export default handleCarnetCreation;

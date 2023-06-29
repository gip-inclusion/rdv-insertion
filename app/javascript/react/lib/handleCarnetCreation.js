import Swal from "sweetalert2";
import createCarnet from "../actions/createCarnet";

const handleCarnetCreation = async (applicant) => {
  const result = await createCarnet(applicant.id, applicant.department.id);
  if (result.success) {
    applicant.updateWith(result.applicant);
  } else {
    Swal.fire("Impossible de créer le carnet", result.errors.join("\n"), "error");
  }
};

export default handleCarnetCreation;

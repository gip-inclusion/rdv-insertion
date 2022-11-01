import Swal from "sweetalert2";
import unarchiveApplicant from "../actions/unarchiveApplicant";

const handleApplicantUnarchive = async (applicant) => {
  const result = await unarchiveApplicant(applicant.id);
  if (result.success) {
    applicant.updateWith(result.applicant);
  } else {
    Swal.fire("Impossible de rouvrir le dossier du bénéficiaire'", result.errors[0], "error");
  }
  return result;
};

export default handleApplicantUnarchive;

import Swal from "sweetalert2";
import createApplicant from "../actions/createApplicant";

const handleApplicantCreation = async (applicant, organisationId) => {
  const result = await createApplicant(applicant, organisationId);
  if (result.success) {
    applicant.updateWith(result.applicant);
  } else {
    Swal.fire("Impossible de créer l'utilisateur", result.errors[0], "error");
  }
};

export default handleApplicantCreation;

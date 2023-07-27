import Swal from "sweetalert2";
import createApplicant from "../actions/createApplicant";

const handleApplicantCreation = async (applicant, organisationId, options = { raiseError: true }) => {
  const result = await createApplicant(applicant, organisationId);
  if (result.success) {
    applicant.updateWith(result.applicant);
  } else if (options.raiseError) Swal.fire("Impossible de créer l'utilisateur", result.errors[0], "error");
  return result
};

export default handleApplicantCreation;

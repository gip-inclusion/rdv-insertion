import Swal from "sweetalert2";
import createApplicant from "../actions/createApplicant";
import createOrUpdateApplicant from "./createOrUpdateApplicant";

const handleApplicantCreation = async (applicant, organisationId) => {
  const result = await createApplicant(applicant, organisationId);
  if (result.success) {
    applicant.updateWith(result.applicant);
  } else if (result.contact_duplicate) {
    await createOrUpdateApplicant(
      applicant,
      result.contact_duplicate,
      result.duplicate_attribute,
      result.duplicate_encrypted_id,
      organisationId
    );
  } else {
    Swal.fire("Impossible de créer l'utilisateur", result.errors[0], "error");
  }
};

export default handleApplicantCreation;

import Swal from "sweetalert2";
import inviteApplicant from "../actions/inviteApplicant";
import createInvitationLetter from "./createInvitationLetter";

const handleApplicantInvitation = async (
  applicantId,
  departmentId,
  organisationId,
  isDepartmentLevel,
  motifCategoryId,
  helpPhoneNumber,
  invitationFormat,
  options = { raiseError: true }
) => {
  if (invitationFormat === "postal") {
    return createInvitationLetter(
      applicantId,
      departmentId,
      organisationId,
      isDepartmentLevel,
      motifCategoryId,
      helpPhoneNumber
    );
  }
  const result = await inviteApplicant(
    applicantId,
    departmentId,
    organisationId,
    isDepartmentLevel,
    invitationFormat,
    helpPhoneNumber,
    motifCategoryId
  );
  if (!result.success && options.raiseError) {
    Swal.fire(
      "Impossible d'inviter l'utilisateur",
      result.errors && result.errors.join("<br/><br/>"),
      "error"
    );
  }
  return result;
};

export default handleApplicantInvitation;

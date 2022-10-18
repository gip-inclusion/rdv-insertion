import Swal from "sweetalert2";
import inviteApplicant from "../actions/inviteApplicant";
import createInvitationLetter from "./createInvitationLetter";

const handleApplicantInvitation = async (
  applicantId,
  departmentId,
  organisationId,
  isDepartmentLevel,
  motifCategory,
  helpPhoneNumber,
  invitationFormat
) => {
  if (invitationFormat === "postal") {
    return createInvitationLetter(
      applicantId,
      departmentId,
      organisationId,
      isDepartmentLevel,
      motifCategory,
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
    motifCategory
  );
  if (!result.success) {
    Swal.fire(
      "Impossible d'inviter l'utilisateur",
      result.errors && result.errors.join("<br/><br/>"),
      "error"
    );
  }
  return result;
};

export default handleApplicantInvitation;

import Swal from "sweetalert2";
import inviteApplicant from "../actions/inviteApplicant";

const handleApplicantInvitation = async (
  applicantId,
  departmentId,
  organisationId,
  isDepartmentLevel,
  motifCategory,
  helpPhoneNumber,
  invitationFormat
) => {
  const result = await inviteApplicant(
    applicantId,
    departmentId,
    organisationId,
    isDepartmentLevel,
    invitationFormat,
    helpPhoneNumber,
    motifCategory
  );
  if (result.success) {
    const { invitation } = result;
    return invitation;
  }
  Swal.fire("Impossible d'inviter l'utilisateur", result.errors[0], "error");
  return result;
};

export default handleApplicantInvitation;

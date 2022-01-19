import Swal from "sweetalert2";
import inviteApplicant from "../actions/inviteApplicant";

const handleApplicantInvitation = async (
  applicantId,
  departmentId,
  organisation,
  isDepartmentLevel,
  invitationFormat
) => {
  const result = await inviteApplicant(
    applicantId,
    departmentId,
    organisation.id,
    isDepartmentLevel,
    invitationFormat,
    organisation.phone_number
  );
  if (result.success) {
    const { invitation } = result;
    return invitation;
  }
  Swal.fire("Impossible d'inviter l'utilisateur", result.errors[0], "error");
  return result;
};

export default handleApplicantInvitation;

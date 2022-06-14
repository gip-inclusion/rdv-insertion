import Swal from "sweetalert2";
import inviteApplicant from "../actions/inviteApplicant";

const handleApplicantInvitation = async (
  applicant,
  departmentId,
  organisation,
  isDepartmentLevel,
  motifCategory,
  numberOfDaysToAcceptInvitation,
  invitationFormat
) => {
  const result = await inviteApplicant(
    applicant,
    departmentId,
    organisation.id,
    isDepartmentLevel,
    invitationFormat,
    organisation.phone_number,
    motifCategory,
    numberOfDaysToAcceptInvitation
  );
  if (result.success) {
    const { invitation } = result;
    return invitation;
  }
  Swal.fire("Impossible d'inviter l'utilisateur", result.errors[0], "error");
  return result;
};

export default handleApplicantInvitation;

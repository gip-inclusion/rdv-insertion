import Swal from "sweetalert2";
import inviteApplicant from "./inviteApplicant";

const handleApplicantInvitation = async (applicant, invitationFormat) => {
  const result = await inviteApplicant(applicant.id, invitationFormat);
  if (result.success) {
    const { invitation } = result;
    return invitation;
  }
  Swal.fire("Impossible d'inviter l'utilisateur", result.errors[0], "error");
  return result;
};

export default handleApplicantInvitation;

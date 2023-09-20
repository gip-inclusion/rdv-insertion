import Swal from "sweetalert2";
import inviteUser from "../actions/inviteUser";
import createInvitationLetter from "./createInvitationLetter";

const handleUserInvitation = async (
  userId,
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
      userId,
      departmentId,
      organisationId,
      isDepartmentLevel,
      motifCategoryId,
      helpPhoneNumber
    );
  }
  const result = await inviteUser(
    userId,
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

export default handleUserInvitation;

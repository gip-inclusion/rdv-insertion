import Swal from "sweetalert2";
import inviteUser from "../actions/inviteUser";
import createInvitationLetter from "./createInvitationLetter";

const handleUserInvitation = async (
  userId,
  departmentId,
  organisationId,
  isDepartmentLevel,
  motifCategoryId,
  invitationFormat,
  options = { raiseError: true }
) => {
  if (invitationFormat === "postal") {
    return createInvitationLetter(
      userId,
      departmentId,
      organisationId,
      isDepartmentLevel,
      motifCategoryId
    );
  }
  const result = await inviteUser(
    userId,
    departmentId,
    organisationId,
    isDepartmentLevel,
    invitationFormat,
    motifCategoryId
  );
  if (!result.success && options.raiseError) {
    Swal.fire(
      "Impossible d'inviter l'usager",
      result.errors && result.errors.join("<br/><br/>"),
      "error"
    );
  }
  return result;
};

export default handleUserInvitation;

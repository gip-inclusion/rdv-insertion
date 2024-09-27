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
    Turbo.renderStreamMessage(result.payload); // eslint-disable-line no-undef
  }
  return result;
};

export default handleUserInvitation;

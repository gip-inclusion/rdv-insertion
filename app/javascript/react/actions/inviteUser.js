import appFetch from "../../lib/appFetch";

const inviteUser = async (
  userId,
  departmentId,
  organisationId,
  isDepartmentLevel,
  invitationFormat,
  helpPhoneNumber,
  motifCategoryId,
  types = "application/json"
) => {
  let url;
  if (isDepartmentLevel) {
    url = `/departments/${departmentId}/users/${userId}/invitations`;
  } else {
    url = `/organisations/${organisationId}/users/${userId}/invitations`;
  }
  return appFetch(
    url,
    "POST",
    {
      invitation_format: invitationFormat,
      help_phone_number: helpPhoneNumber,
      motif_category: { id: motifCategoryId },
    },
    types
  );
};

export default inviteUser;

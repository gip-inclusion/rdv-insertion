import appFetch from "../../lib/appFetch";

const inviteApplicant = async (
  applicantId,
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
    url = `/departments/${departmentId}/applicants/${applicantId}/invitations`;
  } else {
    url = `/organisations/${organisationId}/applicants/${applicantId}/invitations`;
  }
  return appFetch(
    url,
    "POST",
    {
      invitation_format: invitationFormat,
      help_phone_number: helpPhoneNumber,
      motif_category_id: motifCategoryId,
    },
    types
  );
};

export default inviteApplicant;

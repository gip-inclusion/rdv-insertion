import appFetch from "../../lib/appFetch";

const inviteApplicant = async (
  applicant,
  departmentId,
  organisationId,
  isDepartmentLevel,
  invitationFormat,
  helpPhoneNumber,
  motifCategory,
  types = "application/json"
) => {
  let url;
  if (isDepartmentLevel) {
    url = `/departments/${departmentId}/applicants/${applicant.id}/invitations`;
  } else {
    url = `/organisations/${organisationId}/applicants/${applicant.id}/invitations`;
  }
  return appFetch(
    url,
    "POST",
    {
      format: invitationFormat,
      help_phone_number: helpPhoneNumber,
      rdv_context: {
        motif_category: motifCategory,
      },
    },
    types
  );
};

export default inviteApplicant;

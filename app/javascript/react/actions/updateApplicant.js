import appFetch from "../../lib/appFetch";

const updateApplicant = async (organisationOrDepartmentId, applicantId, attributes = {}, level = "organisation") => {
  if (level === "organisation") {
    appFetch(`/organisations/${organisationOrDepartmentId}/applicants/${applicantId}`, "PATCH", {
      applicant: attributes,
    });
  } else {
    appFetch(`/departments/${organisationOrDepartmentId}/applicants/${applicantId}`, "PATCH", {
      applicant: attributes,
    });
  }
}

export default updateApplicant;

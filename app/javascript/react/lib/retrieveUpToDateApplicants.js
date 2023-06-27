import Swal from "sweetalert2";
import searchApplicants from "../actions/searchApplicants";

const retrieveApplicantsFromApp = async (
  departmentId,
  nirs,
  departmentInternalIds,
  uids,
  emails,
  phoneNumbers
) => {
  const result = await searchApplicants(
    departmentId,
    nirs,
    departmentInternalIds,
    uids,
    emails,
    phoneNumbers
  );
  if (result.success) {
    return result.applicants;
  }
  Swal.fire(
    "Une erreur s'est produite en récupérant les infos utilisateurs sur le serveur",
    result.errors && result.errors.join(" - "),
    "warning"
  );
  return null;
};

const retrieveAttributes = (applicants, attributeName) =>
  applicants.map((applicant) => applicant[attributeName]).filter((attribute) => attribute);

const retrieveUpToDateApplicants = async (applicantsFromList, departmentId) => {
  const nirs = retrieveAttributes(applicantsFromList, "nir");
  const departmentInternalIds = retrieveAttributes(applicantsFromList, "departmentInternalId");
  const uids = retrieveAttributes(applicantsFromList, "uid");
  const emails = retrieveAttributes(applicantsFromList, "email");
  const phoneNumbers = retrieveAttributes(applicantsFromList, "phoneNumber");

  const retrievedApplicants = await retrieveApplicantsFromApp(
    departmentId,
    nirs,
    departmentInternalIds,
    uids,
    emails,
    phoneNumbers
  );

  const upToDateApplicants = applicantsFromList.map((applicant) => {
    const upToDateApplicant = retrievedApplicants.find(
      (a) =>
        (a.nir && a.nir.substring(0, 13) === applicant.nir?.substring(0, 13)) ||
        (a.department_internal_id && a.department_internal_id === applicant.departmentInternalId) ||
        (a.uid && a.uid === applicant.uid) ||
        (a.email &&
          a.email === applicant.email &&
          a.first_name.split(" ")[0].toLowerCase() ===
            applicant.firstName.split(" ")[0].toLowerCase()) ||
        (a.phone_number &&
          // since the phone are not formatted in the file we compare the 8 last digits
          a.phone_number.slice(-8) === applicant.phoneNumber?.slice(-8) &&
          a.first_name.split(" ")[0].toLowerCase() ===
            applicant.firstName.split(" ")[0].toLowerCase())
    );

    if (upToDateApplicant) {
      applicant.updateWith(upToDateApplicant);
    }

    return applicant;
  });

  return upToDateApplicants;
};

export default retrieveUpToDateApplicants;

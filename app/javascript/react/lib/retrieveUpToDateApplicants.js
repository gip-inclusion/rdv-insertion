import Swal from "sweetalert2";
import searchApplicants from "../actions/searchApplicants";
import processApplicantsDuplicates from "./processApplicantsDuplicates";

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

const findDuplicates = (arr) => [
  ...new Set(arr.filter((element, index, array) => array.indexOf(element) !== index)),
];

const retrieveUpToDateApplicants = async (applicantsFromList, departmentId) => {
  const nirs = retrieveAttributes(applicantsFromList, "nir");
  const departmentInternalIds = retrieveAttributes(applicantsFromList, "departmentInternalId");
  const uids = retrieveAttributes(applicantsFromList, "uid");
  const emails = retrieveAttributes(applicantsFromList, "email");
  const phoneNumbers = retrieveAttributes(applicantsFromList, "phoneNumber");

  const duplicatesDepartmentInternalIds = findDuplicates(departmentInternalIds);
  const duplicatesUids = findDuplicates(uids);
  const duplicateNirs = findDuplicates(nirs);

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
        (a.nir && a.nir === applicant.nir) ||
        (a.department_internal_id && a.department_internal_id === applicant.departmentInternalId) ||
        (a.uid && a.uid === applicant.uid) ||
        (a.email &&
          a.email === applicant.email &&
          a.first_name.toLowerCase() === applicant.firstName.toLowerCase()) ||
        (a.phone_number &&
          // since the phone are not formatted in the file we compare the 8 last digits
          a.phone_number.slice(-8) === applicant.phoneNumber?.slice(-8) &&
          a.first_name.toLowerCase() === applicant.firstName.toLowerCase())
    );

    if (upToDateApplicant) {
      applicant.updateWith(upToDateApplicant);
    } else if (
      (applicant.nir && duplicateNirs.includes(applicant.nir)) ||
      (applicant.departmentInternalId &&
        duplicatesDepartmentInternalIds.includes(applicant.departmentInternalId)) ||
      (applicant.uid && duplicatesUids.includes(applicant.uid))
    ) {
      processApplicantsDuplicates(applicantsFromList, applicant);
    }
    return applicant;
  });

  return upToDateApplicants;
};

export default retrieveUpToDateApplicants;

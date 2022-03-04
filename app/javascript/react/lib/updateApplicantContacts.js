import retrieveContactPhoneNumber from "../../lib/retrieveContactPhoneNumber";

const updateApplicantContacts = (applicant, applicantContactsData) => {
  if (applicant.phoneNumber == null) {
    applicant.updatePhoneNumber(retrieveContactPhoneNumber(applicantContactsData));
  }
  if (applicant.email == null) {
    applicant.updateEmail(applicantContactsData["ADRESSE ELECTRONIQUE DOSSIER"]);
  }
  return applicant;
};

export default updateApplicantContacts;

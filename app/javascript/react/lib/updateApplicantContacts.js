import retrieveContactPhoneNumber from "../../lib/retrieveContactPhoneNumber";

const updateApplicantContacts = (applicant, applicantContactsData) => {
  if (applicant.phoneNumber == null) {
    applicant.updatePhoneNumber(retrieveContactPhoneNumber(applicantContactsData));
  }
  if (applicant.email == null) {
    applicant.updateEmail(applicantContactsData["ADRESSE ELECTRONIQUE DOSSIER"]);
  }
  if (applicant.rightsOpeningDate == null && applicantContactsData["DATE DEBUT DROITS - DEVOIRS"]) {
    applicant.updateRightsOpeningDate(applicantContactsData["DATE DEBUT DROITS - DEVOIRS"]);
  }
  return applicant;
};

export default updateApplicantContacts;

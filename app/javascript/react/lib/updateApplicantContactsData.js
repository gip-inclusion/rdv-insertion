import retrieveContactPhoneNumber from "../../lib/retrieveContactPhoneNumber";

const updateApplicantContactsData = (applicant, applicantContactsData) => {
  const phoneNumber = retrieveContactPhoneNumber(applicantContactsData);
  if (applicant.phoneNumber == null && phoneNumber) {
    applicant.updatePhoneNumber(phoneNumber);
  }

  const email = applicantContactsData["ADRESSE ELECTRONIQUE DOSSIER"];
  if (applicant.email == null && email) {
    applicant.email = email;
  }

  const rightsOpeningDate = applicantContactsData["DATE DEBUT DROITS - DEVOIRS"];
  if (applicant.rightsOpeningDate == null && rightsOpeningDate) {
    applicant.rightsOpeningDate = rightsOpeningDate;
  }

  return applicant;
};

export default updateApplicantContactsData;

const updateExistingApplicantContactsData = async (
  applicant,
  phoneNumber,
  email,
  rightsOpeningDate
) => {
  if (applicant.phoneNumber !== phoneNumber) {
    applicant.newPhoneNumber = phoneNumber;
  }
  if (applicant.email !== email) {
    applicant.newEmail = email;
  }
  if (applicant.rightsOpeningDate !== rightsOpeningDate) {
    applicant.newRightsOpeningDate = rightsOpeningDate;
  }
  return applicant;
};

const updateNewApplicantContactsData = (applicant, phoneNumber, email, rightsOpeningDate) => {
  if (applicant.phoneNumber == null && phoneNumber) {
    applicant.updatePhoneNumber(phoneNumber);
  }

  if (applicant.email == null && email) {
    applicant.email = email;
  }

  if (applicant.rightsOpeningDate == null && rightsOpeningDate) {
    applicant.rightsOpeningDate = rightsOpeningDate;
  }

  return applicant;
};

const updateApplicantContactsData = (applicant, parsedApplicantContactsData) => {
  const { phoneNumber } = parsedApplicantContactsData;
  const { email } = parsedApplicantContactsData;
  const { rightsOpeningDate } = parsedApplicantContactsData;
  if (applicant.createdAt) {
    return updateExistingApplicantContactsData(applicant, phoneNumber, email, rightsOpeningDate);
  }
  return updateNewApplicantContactsData(applicant, phoneNumber, email, rightsOpeningDate);
};

export default updateApplicantContactsData;

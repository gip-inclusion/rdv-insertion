const retrieveContactPhoneNumber = (userContactsData) => {
  const phoneNumber = userContactsData["NUMERO TELEPHONE DOSSIER"]?.replace(/\s+/g, "");
  const phoneNumber2 = userContactsData["NUMERO TELEPHONE 2 DOSSIER"]?.replace(/\s+/g, "");
  // We want to retrieve a mobile number if possible, but if there is none, we prefer retrieving a number rather than nothing
  if (phoneNumber?.startsWith("06") || phoneNumber?.startsWith("07")) {
    return phoneNumber;
  }
  if (phoneNumber2?.startsWith("06") || phoneNumber2?.startsWith("07")) {
    return phoneNumber2;
  }
  return phoneNumber;
};

const parseContactsData = (userContactsData) => {
  const phoneNumber = retrieveContactPhoneNumber(userContactsData);
  const email = userContactsData["ADRESSE ELECTRONIQUE DOSSIER"]?.replace(/\s+/g, "")?.toLowerCase();

  return { phoneNumber, email };
};

export default parseContactsData;

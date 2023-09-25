import retrieveContactPhoneNumber from "../../lib/retrieveContactPhoneNumber";

const parseContactsData = async (userContactsData) => {
  const phoneNumber = retrieveContactPhoneNumber(userContactsData);
  const email = userContactsData["ADRESSE ELECTRONIQUE DOSSIER"];
  const rightsOpeningDate = userContactsData["DATE DEBUT DROITS - DEVOIRS"];

  return { phoneNumber, email, rightsOpeningDate };
};

export default parseContactsData;

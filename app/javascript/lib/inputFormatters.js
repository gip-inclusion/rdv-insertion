import { excelDateToString, getFrenchFormatDateString } from "./datesHelper"

export const formatInput = (input) => {
  return input?.toString()?.trim()
}

export const formatPhoneNumber = (phoneNumber) => {
  if (!phoneNumber || phoneNumber.length === 0) {
    return null;
  }

  if (phoneNumber[0] === "+") {
    return phoneNumber;
  }
  return phoneNumber[0] !== "0" ? `0${phoneNumber}` : phoneNumber;
};

export const formatAffiliationNumber = (affiliationNumber) => {
  if (!affiliationNumber) return null;

  affiliationNumber = truncateIfOnlyTrailingZeros(affiliationNumber);
  if (affiliationNumber.length <= 7) return affiliationNumber;

  // if affilation number is still longer than 7 characters, we remove leading zeros then try to truncate again
  return truncateIfOnlyTrailingZeros(affiliationNumber.replace(/^0+/, ""));
}

const truncateIfOnlyTrailingZeros = (str) =>
  str.length > 7 && str.slice(7).replace(/0/g, "").length === 0 ? str.slice(0, 7) : str;
;

export const formatTags = (tags) => {
  return tags?.toString()?.split(",")?.map((tag) => tag.trim()) || []
}

export const formatDateInput = (dateInput) => {
  if (!dateInput) return undefined;

  if (typeof dateInput === "number") return excelDateToString(dateInput);

  if (dateInput.search("/") === 2) return dateInput; // in this case, we consider it is a french formatted date

  return getFrenchFormatDateString(dateInput);
};

export const formatAddress = (addressFirstField, addressSecondField, addressThirdField, addressFourthField, addressFifthField) => {
  return (
    (addressFirstField ? `${addressFirstField} ` : "") +
    (addressSecondField ? `${addressSecondField} ` : "") +
    (addressThirdField ? `${addressThirdField} ` : "") +
    (addressFourthField ? `${addressFourthField} ` : "") +
    (addressFifthField ?? "")
  ).trim();
};

const ROLES = {
  usager: "demandeur",
  dem: "demandeur",
  cjt: "conjoint",
};

const TITLES = {
  "m.": "monsieur",
  m: "monsieur",
  mr: "monsieur",
  mme: "madame",
};

export const formatRole = (role) => {
  // CONJOINT/CONCUBIN/PACSE => conjoint
  // CONJOINT(E) => conjoint
  role = role?.split("/")?.shift()?.split("(")?.shift()?.toLowerCase();
  role = ROLES[role] || role;
  if (!Object.values(ROLES).includes(role)) return null;
  return role;
};

export const formatTitle = (title) => {
  title = title?.toLowerCase();
  title = TITLES[title] || title;
  if (!Object.values(TITLES).includes(title)) return null;
  return title;
};


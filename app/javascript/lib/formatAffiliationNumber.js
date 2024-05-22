const formatAffiliationNumber = (affiliationNumber) => {
  if (!affiliationNumber) return null;

  affiliationNumber = truncateIfOnlyTrailingZeros(affiliationNumber);
  if (affiliationNumber.length <= 7) return affiliationNumber;

  // if affilation number is still longer than 7 characters, we remove leading zeros then try to truncate again
  return truncateIfOnlyTrailingZeros(affiliationNumber.replace(/^0+/, ""));
}

const truncateIfOnlyTrailingZeros = (str) =>
  str.length > 7 && str.slice(7).replace(/0/g, "").length === 0 ? str.slice(0, 7) : str;
;

export default formatAffiliationNumber;

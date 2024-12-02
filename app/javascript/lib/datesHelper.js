export const excelDateToJsDate = (serial) => {
  const utcDays = Math.floor(serial - 25569);
  const utcValue = utcDays * 86400;
  return new Date(utcValue * 1000);
};

export const getFrenchFormatDateString = (dateStr) => {
  const date = new Date(dateStr);
  const y = date.getUTCFullYear();
  // JavaScript months are 0-based.
  const m = date.getUTCMonth() + 1;
  const d = date.getUTCDate();
  return `${d < 10 ? `0${d}` : d}/${m < 10 ? `0${m}` : m}/${y}`;
};

export const todaysDateString = () => {
  let date = new Date();
  const offset = date.getTimezoneOffset();
  date = new Date(date.getTime() - offset * 60 * 1000);
  return date.toISOString().split("T")[0];
};

export const excelDateToString = (serial) => getFrenchFormatDateString(excelDateToJsDate(serial));

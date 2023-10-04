export const stringToDate = (dateStr) => {
  const [day, month, year] = dateStr.split("/");
  let date = new Date(year, month - 1, day);
  const offset = date.getTimezoneOffset();
  date = new Date(date.getTime() - offset * 60 * 1000);
  return date;
};

export const applicationStringToDate = (dateStr) => {
  const [year, month, day] = dateStr.split("-");
  return new Date(year, month - 1, day);
};

export const applicationDateToString = (date) => {
  const y = date.getFullYear();
  const m = date.getMonth() + 1;
  const d = date.getDate();
  return `${y}-${m < 10 ? `0${m}` : m}-${d < 10 ? `0${d}` : d}`;
};

export const dateYesterday = (date) => {
  date.setDate(date.getDate() - 1);
  return date;
};

export const yesterdayApplicationDate = (dateStr) =>
  applicationDateToString(dateYesterday(applicationStringToDate(dateStr)));

export const excelDateToJsDate = (serial) => {
  const utcDays = Math.floor(serial - 25569);
  const utcValue = utcDays * 86400;
  return new Date(utcValue * 1000);
};

export const getFrenchFormatDateString = (dateStr) => {
  const date = new Date(dateStr);
  const y = date.getFullYear();
  // JavaScript months are 0-based.
  const m = date.getMonth() + 1;
  const d = date.getDate();
  return `${d < 10 ? `0${d}` : d}/${m < 10 ? `0${m}` : m}/${y}`;
};

export const todaysDateString = () => {
  let date = new Date();
  const offset = date.getTimezoneOffset();
  date = new Date(date.getTime() - offset * 60 * 1000);
  return date.toISOString().split("T")[0];
};

export const excelDateToString = (serial) => getFrenchFormatDateString(excelDateToJsDate(serial));

export function getDateTimeString(date = new Date()) {
  const y = date.getFullYear();
  // JavaScript months are 0-based.
  const m = date.getMonth() + 1;
  const d = date.getDate();
  const h = date.getHours();
  const mi = date.getMinutes();
  const s = date.getSeconds();
  return `${y}_${m < 10 ? `0${m}` : m}_${d < 10 ? `0${d}` : d}_${h < 10 ? `0${h}` : h}_${
    mi < 10 ? `0${mi}` : mi
  }_${s < 10 ? `0${s}` : s}`;
}

export const formatDateInput = (dateInput) => {
  if (!dateInput) return undefined;

  if (typeof dateInput === "number") return excelDateToString(dateInput);

  if (dateInput.search("/") === 2) return dateInput; // in this case, we consider it is a french formatted date

  return getFrenchFormatDateString(dateInput);
};

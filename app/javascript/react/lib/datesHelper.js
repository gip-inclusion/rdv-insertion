export const stringToDate = dateStr => {
  const [day, month, year] = dateStr.split("/");
  return new Date(year, month - 1, day);
};

export const applicationStringToDate = dateStr => {
  const [year, month, day] = dateStr.split("-");
  return new Date(year, month - 1, day);
};

export const applicationDateToString = date => {
  let y = date.getFullYear();
  let m = date.getMonth() + 1;
  let d = date.getDate();
  return y + "-" + (m < 10 ? `0${m}` : m) + "-" + (d < 10 ? `0${d}` : d);
};

export const dateYesterday = date => {
  date.setDate(date.getDate() - 1);
  return date;
};

export const yesterdayApplicationDate = dateStr => {
  return applicationDateToString(dateYesterday(applicationStringToDate(dateStr)));
};

export const excelDateToJsDate = serial => {
  const utc_days = Math.floor(serial - 25569);
  const utc_value = utc_days * 86400;
  return new Date(utc_value * 1000);
};

export const excelDateToString = serial => {
  return getFrenchFormatDateString(excelDateToJsDate(serial));
};

export function getDateTimeString(date = new Date()) {
  let y = date.getFullYear();
  // JavaScript months are 0-based.
  let m = date.getMonth() + 1;
  let d = date.getDate();
  let h = date.getHours();
  let mi = date.getMinutes();
  let s = date.getSeconds();
  return (
    y +
    "_" +
    (m < 10 ? `0${m}` : m) +
    "_" +
    (d < 10 ? `0${d}` : d) +
    "_" +
    (h < 10 ? `0${h}` : h) +
    "_" +
    (mi < 10 ? `0${mi}` : mi) +
    "_" +
    (s < 10 ? `0${s}` : s)
  );
}
export function getFrenchFormatDateString(date) {
  let y = date.getFullYear();
  // JavaScript months are 0-based.
  let m = date.getMonth() + 1;
  let d = date.getDate();
  return (d < 10 ? `0${d}` : d) + "/" + (m < 10 ? `0${m}` : m) + "/" + y;
}

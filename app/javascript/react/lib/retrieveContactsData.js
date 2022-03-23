import * as XLSX from "xlsx";
import getHeaderNames from "./getHeaderNames";
import displayMissingColumnsWarning from "./displayMissingColumnsWarning";

const retrieveContactsData = async (file) => {
  const expectedContactsColumnNames = [
    "MATRICULE",
    "DATE DEBUT DROITS - DEVOIRS",
    "NUMERO TELEPHONE DOSSIER",
    "NUMERO TELEPHONE 2 DOSSIER",
    "ADRESSE ELECTRONIQUE DOSSIER",
  ];
  let contacts = [];

  await new Promise((resolve) => {
    const reader = new FileReader();
    reader.onload = function (event) {
      const sheet = XLSX.read(event.target.result, {
        type: "string",
        cellDates: true,
        dateNF: "dd/mm/yyyy",
      }).Sheets.Sheet1;
      const headerNames = getHeaderNames(sheet);
      const missingColumnNames = [];
      expectedContactsColumnNames.forEach((col) => {
        if (!headerNames.includes(col)) missingColumnNames.push(col);
      });
      if (missingColumnNames.length > 0) {
        displayMissingColumnsWarning(missingColumnNames);
      } else {
        contacts = XLSX.utils.sheet_to_json(sheet, { raw: false });
      }
      resolve();
    };
    reader.readAsBinaryString(file);
  });
  return contacts;
};

export default retrieveContactsData;

import * as XLSX from "xlsx";
import { parameterizeObjectKeys, parameterizeArray } from "../../lib/parameterize";
import displayMissingColumnsWarning from "./displayMissingColumnsWarning";
import checkColumnNames from "./checkColumnNames";
import getHeaderNames from "./getHeaderNames";

export default async function uploadFile(file, sheetName, columnNames) {
  return new Promise((resolve) => {
    const reader = new FileReader();
    reader.onload = function (event) {
      const workbook = XLSX.read(event.target.result, { type: "binary" });
      const sheet = workbook.Sheets[sheetName] || workbook.Sheets[workbook.SheetNames[0]];
      const headerNames = getHeaderNames(sheet);
      const missingColumnNames = checkColumnNames(columnNames, parameterizeArray(headerNames));
      if (missingColumnNames.length > 0) {
        displayMissingColumnsWarning(missingColumnNames);
      } else {
        let rows = XLSX.utils.sheet_to_row_object_array(sheet);
        rows = rows.map((row) => parameterizeObjectKeys(row));

        resolve(rows);
      }
    };
    reader.readAsBinaryString(file);
  });
}
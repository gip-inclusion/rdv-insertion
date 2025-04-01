import * as XLSX from "xlsx";
import { parameterizeArray } from "./parameterize";
import safeSwal from "./safeSwal";

export const retrieveSheetColumnNames = (sheet) => {
  const header = [];
  const columnCount = XLSX.utils.decode_range(sheet["!ref"]).e.c + 1;
  for (let i = 0; i < columnCount; i += 1) {
    if (sheet[`${XLSX.utils.encode_col(i)}1`] !== undefined) {
      header[i] = sheet[`${XLSX.utils.encode_col(i)}1`].v;
    }
  }
  return header;
}

export const retrieveMissingColumnNames = (sheetColumnNames, expectedColumnNames) => {
  const missingColumnIndices = []
  const expectedColumnNamesParameterized = parameterizeArray(expectedColumnNames)
  const sheetColumnNamesParameterized = parameterizeArray(sheetColumnNames)

  expectedColumnNamesParameterized.forEach((colName, index) => {
    if (!sheetColumnNamesParameterized.includes(colName)) {
      missingColumnIndices.push(index)
    }
  })
  return expectedColumnNames.filter((_, index) => missingColumnIndices.includes(index))
};

export const displayMissingColumnsWarning = (missingColumnNames) => {
  safeSwal({
    title: "Le fichier chargé ne correspond pas au format attendu",
    html: `Veuillez vérifier que les colonnes suivantes sont présentes et correctement nommées&nbsp;:
      <br/>
      <strong>${missingColumnNames.join("<br />")}</strong>`,
    icon: "error",
  });
};

export const validateFileFormat = (file, acceptedFormats) => {
  if (!acceptedFormats.some((format) => file.name.endsWith(format))) {
    safeSwal({
      title: `Le fichier doit être au format ${acceptedFormats.join(", ")}`,
      icon: "error",
    });
    return false
  }
  return true
};

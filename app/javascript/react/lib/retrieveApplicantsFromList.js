import * as XLSX from "xlsx";
import getHeaderNames from "./getHeaderNames";
import getKeyByValue from "../../lib/getKeyByValue";
import displayMissingColumnsWarning from "./displayMissingColumnsWarning";
import { excelDateToString } from "../../lib/datesHelper";
import {
  parameterizeObjectKeys,
  parameterizeObjectValues,
  parameterizeArray,
} from "../../lib/parameterize";

import Applicant from "../models/Applicant";

const checkColumnNames = (columnNames, configuration, uploadedColumnNamesParameterized) => {
  const missingColumnNames = [];
  const requiredColumnsMapping = parameterizeObjectValues(columnNames.required);

  const expectedColumnNamesParameterized = Object.values(requiredColumnsMapping);
  const parameterizedMissingColumns = expectedColumnNamesParameterized.filter(
    (colName) => !uploadedColumnNamesParameterized.includes(colName)
  );

  if (parameterizedMissingColumns.length > 0) {
    // Récupère les noms "humains" des colonnes manquantes
    parameterizedMissingColumns.forEach((col) => {
      const missingAttribute = getKeyByValue(requiredColumnsMapping, col);
      const missingColumnName = configuration.column_names.required[missingAttribute];
      missingColumnNames.push(missingColumnName);
    });
  }
  return missingColumnNames;
};

const retrieveApplicantsFromList = async (
  file,
  organisation,
  department,
  configuration,
  columnNames,
  parameterizedColumnNames
) => {
  const applicantsFromList = [];

  await new Promise((resolve) => {
    const reader = new FileReader();
    reader.onload = function (event) {
      const sheetName = configuration.sheet_name;
      const workbook = XLSX.read(event.target.result, { type: "binary" });
      const sheet = workbook.Sheets[sheetName] || workbook.Sheets[workbook.SheetNames[0]];
      const headerNames = getHeaderNames(sheet);
      const missingColumnNames = checkColumnNames(
        columnNames,
        configuration,
        parameterizeArray(headerNames)
      );
      if (missingColumnNames.length > 0) {
        displayMissingColumnsWarning(missingColumnNames);
      } else {
        let rows = XLSX.utils.sheet_to_row_object_array(sheet);
        rows = rows.map((row) => parameterizeObjectKeys(row));
        rows.forEach((row) => {
          const applicant = new Applicant(
            {
              lastName: row[parameterizedColumnNames.last_name],
              firstName: row[parameterizedColumnNames.first_name],
              affiliationNumber: row[parameterizedColumnNames.affiliation_number],
              role: row[parameterizedColumnNames.role],
              title: row[parameterizedColumnNames.title],
              address: parameterizedColumnNames.address && row[parameterizedColumnNames.address],
              fullAddress:
                parameterizedColumnNames.full_address && row[parameterizedColumnNames.full_address],
              email: parameterizedColumnNames.email && row[parameterizedColumnNames.email],
              birthDate:
                parameterizedColumnNames.birth_date &&
                row[parameterizedColumnNames.birth_date] &&
                excelDateToString(row[parameterizedColumnNames.birth_date]),
              city: parameterizedColumnNames.city && row[parameterizedColumnNames.city],
              postalCode:
                parameterizedColumnNames.postal_code && row[parameterizedColumnNames.postal_code],
              phoneNumber:
                parameterizedColumnNames.phone_number && row[parameterizedColumnNames.phone_number],
              birthName:
                parameterizedColumnNames.birth_name && row[parameterizedColumnNames.birth_name],
              departmentInternalId:
                parameterizedColumnNames.department_internal_id &&
                row[parameterizedColumnNames.department_internal_id],
              rightsOpeningDate:
                parameterizedColumnNames.rights_opening_date &&
                row[parameterizedColumnNames.rights_opening_date] &&
                excelDateToString(row[parameterizedColumnNames.rights_opening_date]),
            },
            department,
            organisation,
            configuration
          );
          applicantsFromList.push(applicant);
        });
      }
      resolve();
    };
    reader.readAsBinaryString(file);
  });

  return applicantsFromList.reverse();
};

export default retrieveApplicantsFromList;

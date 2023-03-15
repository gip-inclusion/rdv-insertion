import getKeyByValue from "../../lib/getKeyByValue";
import { parameterizeObjectValues } from "../../lib/parameterize";

const checkColumnNames = (columnNames, uploadedColumnNamesParameterized) => {
  const missingColumnNames = [];
  const requiredColumnsMapping = parameterizeObjectValues(columnNames);

  const expectedColumnNamesParameterized = Object.values(requiredColumnsMapping);
  const parameterizedMissingColumns = expectedColumnNamesParameterized.filter(
    (colName) => !uploadedColumnNamesParameterized.includes(colName)
  );

  if (parameterizedMissingColumns.length > 0) {
    // Récupère les noms "humains" des colonnes manquantes
    parameterizedMissingColumns.forEach((col) => {
      const missingAttribute = getKeyByValue(requiredColumnsMapping, col);
      const missingColumnName = columnNames[missingAttribute];
      missingColumnNames.push(missingColumnName);
    });
  }
  return missingColumnNames;
};

export default checkColumnNames;

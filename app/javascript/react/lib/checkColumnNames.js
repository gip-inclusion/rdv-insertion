import getKeyByValue from "../../lib/getKeyByValue";
import { parameterizeObjectValues } from "../../lib/parameterize";

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

export default checkColumnNames;

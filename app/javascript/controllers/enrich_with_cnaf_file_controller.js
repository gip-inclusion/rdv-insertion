import { Controller } from "@hotwired/stimulus";
import * as XLSX from "xlsx";
import safeSwal from "../lib/safeSwal";
import { retrieveMissingColumnNames, retrieveSheetColumnNames, displayMissingColumnsWarning, validateFileFormat } from "../lib/fileParser";
import parseContactsData from "../lib/parseContactsData";

export default class extends Controller {
  static targets = ["input", "form", "button", "buttonText", "spinner"]

  connect() {
    this.userRows = JSON.parse(this.element.dataset.userRows)
  }

  async submit(event) {
    event.preventDefault()
    const file = event.target.files[0]

    if (!file) {
      return
    }

    this.#setLoadingState(true)

    if (!validateFileFormat(file, this.#acceptedFileFormats())) {
      this.inputTarget.value = ""
      this.#setLoadingState(false)
      return
    }
    if (!await this.#readFile(file)) {
      this.inputTarget.value = ""
      this.#setLoadingState(false)
      return
    }

    this.rowsCnafData = []

    this.#retrieveRowsCnafData()

    if (this.rowsCnafData.length === 0) {
      safeSwal({
        title: "Aucun usager trouvé",
        text: "Aucun usager trouvé dans le fichier CNAF",
        icon: "warning",
        confirmButtonText: "OK"
      })
      this.inputTarget.value = ""
      this.#setLoadingState(false)
      return
    }

    this.#insertFormInputs()

    await this.formTarget.requestSubmit()
  }

  #setLoadingState(isLoading) {
    this.buttonTarget.disabled = isLoading
    this.buttonTextTarget.textContent = isLoading ? "Enrichissement des données..." : "Enrichir avec les données CNAF"
    this.spinnerTarget.classList.toggle("d-none", !isLoading)
  }

  #insertFormInputs() {
    // we make sure to remove existing inputs from previous submissions
    this.#removeExistingInputs()

    this.rowsCnafData.forEach((row) => {
      const idInput = document.createElement("input")
      idInput.type = "hidden"
      idInput.name = "rows_cnaf_data[][id]"
      idInput.value = row.id

      // Create separate inputs for each cnaf_data field
      const emailInput = document.createElement("input")
      emailInput.type = "hidden"
      emailInput.name = "rows_cnaf_data[][cnaf_data][email]"
      emailInput.value = row.cnaf_data.email

      const phoneInput = document.createElement("input")
      phoneInput.type = "hidden"
      phoneInput.name = "rows_cnaf_data[][cnaf_data][phone_number]"
      phoneInput.value = row.cnaf_data.phone_number

      const dateInput = document.createElement("input")
      dateInput.type = "hidden"
      dateInput.name = "rows_cnaf_data[][cnaf_data][rights_opening_date]"
      dateInput.value = row.cnaf_data.rights_opening_date

      this.formTarget.appendChild(idInput)
      this.formTarget.appendChild(emailInput)
      this.formTarget.appendChild(phoneInput)
      this.formTarget.appendChild(dateInput)
    })

  }

  #removeExistingInputs() {
    const existingInputs = this.formTarget.querySelectorAll("input[name^='rows_cnaf_data']")
    existingInputs.forEach(input => input.remove())
  }

  #acceptedFileFormats() {
    return this.inputTarget.accept.split(",").map((format) => format.trim())
  }

  #retrieveRowsCnafData() {
    this.userRows.forEach((userRow) => {
      if (!userRow.affiliation_number && !userRow.nir) {
        return
      }

      const matchingCnafDataRow = this.#findCnafDataByNir(userRow.nir) || this.#findCnafDataByAffiliationNumber(userRow.affiliation_number);

      if (matchingCnafDataRow) {
        const parsedCnafData = parseContactsData(matchingCnafDataRow)
        this.rowsCnafData.push({
          id: userRow.id,
          cnaf_data: {
            email: parsedCnafData.email || "",
            phone_number: parsedCnafData.phoneNumber || "",
            rights_opening_date: parsedCnafData.rightsOpeningDate || ""
          }
        })
      }
    })
  }

  #findCnafDataByNir(nir) {
    if (!nir) return null;

    return this.cnafDataRows.find((cnafDataRow) =>
      cnafDataRow.NIR && nir.slice(0, 13) === cnafDataRow.NIR.slice(0, 13)
    );
  }

  #findCnafDataByAffiliationNumber(affiliationNumber) {
    if (!affiliationNumber) return null;

    return this.cnafDataRows.find((cnafDataRow) =>
      cnafDataRow.MATRICULE &&
      affiliationNumber.toString().padStart(7, "0") === cnafDataRow.MATRICULE.toString().padStart(7, "0")
    );
  }

  #readFile(file) {
    const expectedContactsColumnNames = [
      "MATRICULE",
      "DATE DEBUT DROITS - DEVOIRS",
      "NUMERO TELEPHONE DOSSIER",
      "NUMERO TELEPHONE 2 DOSSIER",
      "ADRESSE ELECTRONIQUE DOSSIER",
    ];

    return new Promise((resolve) => {
      const reader = new FileReader();
      reader.onload = (event) => {
        const sheet = XLSX.read(event.target.result, {
          type: "string",
          cellDates: true,
          dateNF: "dd/mm/yyyy",
        }).Sheets.Sheet1;
        const sheetColumnNames = retrieveSheetColumnNames(sheet);
        const missingColumnNames = retrieveMissingColumnNames(sheetColumnNames, expectedContactsColumnNames);
        if (missingColumnNames.length > 0) {
          displayMissingColumnsWarning(missingColumnNames);
          resolve(false);
        } else {
          this.cnafDataRows = XLSX.utils.sheet_to_json(sheet, { raw: false });
          resolve(true);
        }
      };
      reader.readAsArrayBuffer(file);
    });
  }
}

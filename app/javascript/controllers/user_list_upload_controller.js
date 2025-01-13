import { Controller } from "@hotwired/stimulus"
import * as XLSX from "xlsx"
import { retrieveSheetColumnNames, retrieveMissingColumnNames, displayMissingColumnsWarning, validateFileFormat } from "../lib/fileParser"
import { parameterizeObjectKeys, parameterizeObjectValues } from "../lib/parameterize"
import { formatInput, formatAffiliationNumber, formatDateInput, formatAddress, formatRole, formatTitle, formatPhoneNumber, formatTags } from "../lib/inputFormatters"

export default class extends Controller {
  static targets = ["dropZone", "input", "uploadedFileInfo", "fileName", "fileInputInstruction", "userCount", "submitButton"]

  connect() {
    this.fileConfigurationColumnAttributes = JSON.parse(this.element.dataset.fileConfigurationColumnAttributes)
    this.fileConfigurationSheetName = this.element.dataset.fileConfigurationSheetName
  }

  handleDragOver(event) {
    event.preventDefault()
    this.dropZoneTarget.classList.add("drag-over")
  }

  handleDragLeave(event) {
    event.preventDefault()
    this.dropZoneTarget.classList.remove("drag-over")
  }

  async handleDrop(event) {
    event.preventDefault()
    this.dropZoneTarget.classList.remove("drag-over")

    const file = event.dataTransfer.files[0]
    if (file) {
      await this.#processFile(file)
    }
  }

  async handleFileSelect(event) {
    const file = event.target.files[0]
    if (file) {
      await this.#processFile(file)
    }
  }

  handleFileRemove() {
    this.inputTarget.value = ""
    this.#updateFileName("")
    this.#updateUserCount("")
    this.fileInputInstructionTarget.classList.remove("d-none")
    this.uploadedFileInfoTarget.classList.add("d-none")
  }

  async handleSubmit(event) {
    event.preventDefault()

    const button = this.submitButtonTarget
    const { form } = event.target

    this.#setLoading(button)

    this.userList = this.#transformRowsInUserList(this.rows)

    form.querySelector("input[name='file_name']").value = this.fileNameTarget.textContent

    // First, remove any existing hidden inputs from previous submissions
    const existingInputs = form.querySelectorAll("input[name^='user_list[']")
    existingInputs.forEach(input => input.remove())

    this.#addInputsToForm(form)


    form.addEventListener("turbo:submit-end", () => {
      this.#resetLoading(button)
    })

    form.requestSubmit()
  }

  #addInputsToForm(form) {
    this.userList.forEach((user) => {
      Object.entries(user).forEach(([attribute, value]) => {
        if (value !== null && value !== undefined) {
          if (Array.isArray(value)) {
            value.forEach((item) => {
              const input = document.createElement("input")
              input.type = "hidden"
              input.name = `user_list[][${attribute}][]`
              input.value = item
              form.appendChild(input)
            })
          } else {
            const input = document.createElement("input")
            input.type = "hidden"
            input.name = `user_list[][${attribute}]`
            input.value = value
            form.appendChild(input)
          }
        }
      })
    })
  }

  #setLoading(button) {
    button.value = "Chargement des données usagers..."
    button.classList.add("disabled")
  }

  #resetLoading(button) {
    button.value = "Charger les données usagers"
    button.classList.remove("disabled")
    button.removeAttribute("disabled")
  }

  #transformRowsInUserList(rows) {
    const parameterizedColumnAttributes = parameterizeObjectValues(this.fileConfigurationColumnAttributes)
    return rows.map((row) => {
      return {
        first_name: formatInput(row[parameterizedColumnAttributes.first_name_column]),
        last_name: formatInput(row[parameterizedColumnAttributes.last_name_column]),
        affiliation_number: formatAffiliationNumber(formatInput(row[parameterizedColumnAttributes.affiliation_number_column])),
        role: formatRole(row[parameterizedColumnAttributes.role_column]),
        title: formatTitle(row[parameterizedColumnAttributes.title_column]),
        nir: formatInput(row[parameterizedColumnAttributes.nir_column]),
        department_internal_id: formatInput(row[parameterizedColumnAttributes.department_internal_id_column]),
        france_travail_id: formatInput(row[parameterizedColumnAttributes.france_travail_id_column]),
        tags: formatTags(row[parameterizedColumnAttributes.tags_column]),
        birth_date: formatDateInput(row[parameterizedColumnAttributes.birth_date_column]),
        birth_name: formatInput(row[parameterizedColumnAttributes.birth_name_column]),
        phone_number: formatPhoneNumber(formatInput(row[parameterizedColumnAttributes.phone_number_column])),
        email: formatInput(row[parameterizedColumnAttributes.email_column]),
        address: formatAddress(
          row[parameterizedColumnAttributes.address_first_field_column],
          row[parameterizedColumnAttributes.address_second_field_column],
          row[parameterizedColumnAttributes.address_third_field_column],
          row[parameterizedColumnAttributes.address_fourth_field_column],
          row[parameterizedColumnAttributes.address_fifth_field_column]
        ),
        rights_opening_date: formatDateInput(row[parameterizedColumnAttributes.rights_opening_date_column]),
        referent_email: formatInput(row[parameterizedColumnAttributes.referent_email_column]),
        organisation_search_terms: formatInput(row[parameterizedColumnAttributes.organisation_search_terms_column]),
      }
    })
  }

  async #processFile(file) {
    const acceptedFormats = this.inputTarget.accept.split(",").map((format) => format.trim())
    if (validateFileFormat(file, acceptedFormats)) {
      if (await this.#readFile(file)) {
        this.#setFileSelected(file)
      } else {
        this.inputTarget.value = ""
      }
    }
  }

  async #readFile(file) {
    return new Promise((resolve) => {
      const reader = new FileReader();
      reader.onload = (event) => {
        const workbook = XLSX.read(event.target.result, { type: "binary" });
        const sheet = workbook.Sheets[this.fileConfigurationSheetName] || workbook.Sheets[workbook.SheetNames[0]];
        const sheetColumnNames = retrieveSheetColumnNames(sheet);
        const missingColumnNames = retrieveMissingColumnNames(sheetColumnNames, Object.values(this.fileConfigurationColumnAttributes));
        if (missingColumnNames.length > 0) {
          displayMissingColumnsWarning(missingColumnNames);
          resolve(false);
        } else {
          this.rows = XLSX.utils.sheet_to_row_object_array(sheet);
          this.rows = this.rows.map((row) => parameterizeObjectKeys(row));

          resolve(true);
        }
      };
      reader.readAsArrayBuffer(file);
    });
  }

  #setFileSelected(file) {
    this.#updateFileName(file.name)
    this.#updateUserCount(this.rows.length)
    this.fileInputInstructionTarget.classList.add("d-none")
    this.uploadedFileInfoTarget.classList.remove("d-none")
    this.submitButtonTarget.classList.remove("disabled")
  }

  #updateFileName(name) {
    this.fileNameTarget.textContent = name
  }

  #updateUserCount(count) {
    this.userCountTarget.textContent = count > 0 ? `${count} usagers à importer` : "Aucun usager à importer"
  }
}

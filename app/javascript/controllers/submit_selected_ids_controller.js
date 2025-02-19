import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["checkbox", "submit", "formatOption", "selectedUsersCounter"]

  connect() {
    if (this.hasSubmitTarget) {
      this.toggleSubmit()
    }
    this.#updateSelectedCount()
  }

  submit(event) {
    const selectedIds = this.checkboxTargets
      .filter(checkbox => checkbox.checked)
      .map(checkbox => checkbox.value)

    const form = event.currentTarget

    // Remove any existing hidden fields first
    form.querySelectorAll("input[name='selected_ids[]']").forEach(el => el.remove())

    // Create a new hidden field for each UID
    selectedIds.forEach(id => {
      const hiddenField = document.createElement("input")
      hiddenField.type = "hidden"
      hiddenField.name = "selected_ids[]"
      hiddenField.value = id
      form.appendChild(hiddenField)
    })
  }

  toggleAll(event) {
    this.checkboxTargets.forEach(checkbox => {
      checkbox.checked = checkbox.disabled ? false : event.target.checked
    })
    this.toggleSubmit()
  }

  toggleSubmit() {
    if (this.#atLeastOneCheckboxChecked()) {
      this.#enableSubmit()
    } else {
      this.#disableSubmit()
    }
    this.#updateSelectedCount()
  }

  disableUninvitableUsers() {
    const supportedFormats = this.formatOptionTargets.filter(option => option.checked).map(option => option.dataset.format)

    this.checkboxTargets.forEach(checkbox => {
      const isInvitable = checkbox.dataset.userInvitable === "true" &&
                          ((supportedFormats.includes("email") && !!checkbox.dataset.userEmail) ||
                          (supportedFormats.includes("sms") && !!checkbox.dataset.userPhone))

      if (isInvitable) {
        checkbox.checked = true
        checkbox.disabled = false
      } else {
        checkbox.checked = false
        checkbox.disabled = true
      }
    })

    this.toggleSubmit()
  }

  #disableSubmit() {
    this.submitTarget.disabled = true
  }

  #enableSubmit() {
    this.submitTarget.disabled = false
  }

  #atLeastOneCheckboxChecked() {
    return this.checkboxTargets.filter(checkbox => checkbox.checked).length > 0
  }

  #updateSelectedCount() {
    const selectedCount = this.checkboxTargets.filter(checkbox => checkbox.checked).length

    let textContent = ""
    if (selectedCount === 0) textContent = "Aucun usager sélectionné"
    else if (selectedCount === 1) textContent = "1 usager sélectionné"
    else textContent = `${selectedCount} usagers sélectionnés`

    this.selectedUsersCounterTarget.textContent = textContent
  }
}


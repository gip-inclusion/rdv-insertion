import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["checkbox", "submit", "formatOption"]

  connect() {
    if (this.hasSubmitTarget) {
      this.toggleSubmit()
    }
  }

  submit(event) {
    const selectedUids = this.checkboxTargets
      .filter(checkbox => checkbox.checked)
      .map(checkbox => checkbox.value)

    const form = event.currentTarget

    // Remove any existing hidden fields first
    form.querySelectorAll("input[name='selected_uids[]']").forEach(el => el.remove())

    // Create a new hidden field for each UID
    selectedUids.forEach(uid => {
      const hiddenField = document.createElement("input")
      hiddenField.type = "hidden"
      hiddenField.name = "selected_uids[]"
      hiddenField.value = uid
      form.appendChild(hiddenField)
    })
  }

  toggleAll(event) {
    this.checkboxTargets.forEach(checkbox => {
      checkbox.checked = event.target.checked && !checkbox.disabled
    })
    this.toggleSubmit()
  }

  toggleSubmit() {
    if (this.#atLeastOneCheckboxChecked()) {
      this.#enableSubmit()
    } else {
      this.#disableSubmit()
    }
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
}


import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "enable",
    "numberOfDays",
    "limitIndicator",
    "inputGroup"
  ]

  static minValueForNumberOfDays = 1

  connect() {
    this.showIndicator()
  }

  toggleInvitationExpiration() {
    this.numberOfDaysTarget.readOnly = !this.enableTarget.checked
    this.numberOfDaysTarget.value = this.enableTarget.checked ? 1 : null

    this.element.classList.toggle("disabled", !this.enableTarget.checked)
    this.showIndicator()
  }

  showIndicator() {
    if (this.enableTarget.checked) {
      this.limitIndicatorTarget.classList.add("d-none")
      this.inputGroupTarget.classList.remove("d-none")
    } else {
      this.limitIndicatorTarget.classList.remove("d-none")
      this.inputGroupTarget.classList.add("d-none")
    }
  }
}

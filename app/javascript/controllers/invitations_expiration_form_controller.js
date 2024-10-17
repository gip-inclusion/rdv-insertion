import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "enable",
    "numberOfDays",
    "noLimitMessage",
    "inputGroup"
  ]

  static minValueForNumberOfDays = 1

  connect() {
    this.toggleElementsVisibility()
  }

  disable() {
    this.enableTarget.checked = false
    this.toggleInvitationExpiration()
  }

  toggleInvitationExpiration() {
    this.numberOfDaysTarget.readOnly = !this.enableTarget.checked
    this.numberOfDaysTarget.value = this.enableTarget.checked ? 10 : null

    this.element.classList.toggle("disabled", !this.enableTarget.checked)
    this.toggleElementsVisibility()
  }

  toggleElementsVisibility() {
    if (this.enableTarget.checked) {
      this.noLimitMessageTarget.classList.add("d-none")
      this.inputGroupTarget.classList.remove("d-none")
      this.disablePeriodicInvites()
    } else {
      this.noLimitMessageTarget.classList.remove("d-none")
      this.inputGroupTarget.classList.add("d-none")
    }
  }

  disablePeriodicInvites() {
    const periodicInvitesFormController = this.application.getControllerForElementAndIdentifier(
      document.querySelector("[data-controller=\"periodic-invites-form\"]"), 
      "periodic-invites-form"
    );

    
    if (periodicInvitesFormController) {
      periodicInvitesFormController.disable();
    }
  }
}

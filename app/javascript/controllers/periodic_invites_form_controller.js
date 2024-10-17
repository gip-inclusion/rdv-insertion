import { Controller } from "@hotwired/stimulus";
import tippy from "tippy.js";

export default class extends Controller {
  static targets = [
    "enable",
    "numberOfDays",
    "dayOfTheMonth",
    "nextInviteIndicator",
    "typeRadio"
  ]

  static minValueForNumberOfDays = 14

  connect() {
    this.periodicityTypeChanged()
  }

  disable() {
    this.enableTarget.checked = false
    this.togglePeriodicInvites()
  }

  periodicityTypeChanged() {
    if (this.typeRadioTargets[0].checked) {
      this.numberOfDaysInputChanged()
    } else if (this.typeRadioTargets[1].checked) {
      this.dayOfTheMonthInputChanged()
    }
  }

  togglePeriodicInvites() {
    if (this.enableTarget.checked) this.disableInvitationsExpiration()

    this.numberOfDaysTarget.readOnly = !this.enableTarget.checked
    this.numberOfDaysTarget.value = this.enableTarget.checked ? this.constructor.minValueForNumberOfDays : null
    this.dayOfTheMonthTarget.readOnly = !this.enableTarget.checked
    this.typeRadioTargets[0].checked = this.enableTarget.checked 
    this.typeRadioTargets[1].checked = false
    this.dayOfTheMonthTarget.value = null

    this.element.classList.toggle("disabled", !this.enableTarget.checked)
    this.typeRadioTargets.forEach((input) => {
      input.disabled = !this.enableTarget.checked
    })

    this.showIndicator()
  }

  numberOfDaysInputChanged() {
    if (this.numberOfDaysTarget.value < this.constructor.minValueForNumberOfDays) {
      const tooltip = tippy(this.numberOfDaysTarget, { content: "Le délai minimal entre 2 invitations est de 14 jours.", showOnCreate: true })

      // We destroy the tooltip so that it won't show up again unless the 
      // user intentionnaly sets another value under the threshold
      setTimeout(() => tooltip.destroy(), 2000)

      this.numberOfDaysTarget.value = this.constructor.minValueForNumberOfDays
    }
    this.dayOfTheMonthTarget.value = null
    this.typeRadioTargets[0].checked = true
    this.typeRadioTargets[1].checked = false
    this.showIndicator()
  }
  
  dayOfTheMonthInputChanged() {
    if (this.dayOfTheMonthTarget.value < 1) this.dayOfTheMonthTarget.value = 1
    if (this.dayOfTheMonthTarget.value > 31) this.dayOfTheMonthTarget.value = 31
    this.numberOfDaysTarget.value = null
    this.typeRadioTargets[0].checked = false
    this.typeRadioTargets[1].checked = true
    this.showIndicator()
  }

  showIndicator() {
    if (!this.enableTarget.checked) {
      this.nextInviteIndicatorTarget.innerHTML = "Les invitations périodiques sont désactivées."
      return
    }

    if (this.numberOfDaysTarget.value) {
      this.nextInviteIndicatorTarget.innerHTML = `Une invitation sera envoyée ${this.numberOfDaysTarget.value} jour(s) suivant la dernière invitation.`
    } else if (this.dayOfTheMonthTarget.value) {
      this.nextInviteIndicatorTarget.innerHTML = `Une invitation sera envoyée le ${this.dayOfTheMonthTarget.value} de chaque mois.`
    } else if (this.enable.checked) {
      this.nextInviteIndicatorTarget.innerHTML = "Vous devez configurer la récurrence afin d'activer les invitations périodiques."
    }
  }

  disableInvitationsExpiration() {
    const invitationsExpirationFormController = this.application.getControllerForElementAndIdentifier(
      document.querySelector("[data-controller=\"invitations-expiration-form\"]"), 
      "invitations-expiration-form"
    );

    if (invitationsExpirationFormController) {
      invitationsExpirationFormController.disable();
    }
  }
}

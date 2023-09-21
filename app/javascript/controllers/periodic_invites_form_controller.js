import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "enable",
    "numberOfDays",
    "dayOfTheMonth",
    "nextInviteIndicator",
    "typeRadio"
  ]

  connect() {
    this.togglePeriodicInvites()
    this.periodicityTypeChanged()
  }

  periodicityTypeChanged() {
    if (this.typeRadioTargets[0].checked) {
      this.numberOfDaysInputChanged()
    } else if (this.typeRadioTargets[1].checked) {
      this.dayOfTheMonthInputChanged()
    }
  }

  togglePeriodicInvites() {
    this.numberOfDaysTarget.disabled = !this.enableTarget.checked
    this.numberOfDaysTarget.value = this.enableTarget.checked ? 10 : null
    this.dayOfTheMonthTarget.disabled = !this.enableTarget.checked
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
    if (this.numberOfDaysTarget.value < 10) this.numberOfDaysTarget.value = 10
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
}

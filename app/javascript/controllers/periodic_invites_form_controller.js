import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.enableInput = this.element.querySelector("#configuration_periodic_invites_enabled")
    this.numberOfDaysInput = this.element.querySelector("#configuration_number_of_days_between_periodic_invites")
    this.dayOfTheMonthInput = this.element.querySelector("#configuration_day_of_the_month_periodic_invites")
    this.nextInviteIndicator = this.element.querySelector("#next-invite-indicator")
    this.typeRadio = this.element.querySelectorAll("input[name=\"periodicity-type\"]")
    this.togglePeriodicInvites();
    this.periodicityTypeChanged()

    this.enableInput.addEventListener("change", this.togglePeriodicInvites.bind(this));
    this.numberOfDaysInput.addEventListener("change", this.numberOfDaysInputChanged.bind(this));
    this.dayOfTheMonthInput.addEventListener("change", this.dayOfTheMonthInputChanged.bind(this));
    this.typeRadio.forEach((input) => {
      input.addEventListener("change", () => this.periodicityTypeChanged())
    })
  }

  periodicityTypeChanged() {
    if (this.typeRadio[0].checked) {
      this.numberOfDaysInputChanged()
    } else if (this.typeRadio[1].checked) {
      this.dayOfTheMonthInputChanged()
    }
  }

  togglePeriodicInvites() {
    this.numberOfDaysInput.disabled = !this.enableInput.checked
    this.dayOfTheMonthInput.disabled = !this.enableInput.checked
    this.element.classList.toggle("disabled", !this.enableInput.checked)
    this.typeRadio.forEach((input) => {
      input.disabled = !this.enableInput.checked
    })

    this.showIndicator()
  }

  numberOfDaysInputChanged() {
    if (this.numberOfDaysInput.value < 1) this.numberOfDaysInput.value = 1
    this.dayOfTheMonthInput.value = null
    this.typeRadio[0].checked = true
    this.typeRadio[1].checked = false
    this.showIndicator()
  }
  
  dayOfTheMonthInputChanged() {
    if (this.dayOfTheMonthInput.value < 1) this.dayOfTheMonthInput.value = 1
    if (this.dayOfTheMonthInput.value > 31) this.dayOfTheMonthInput.value = 31
    this.numberOfDaysInput.value = null
    this.typeRadio[0].checked = false
    this.typeRadio[1].checked = true
    this.showIndicator()
  }

  showIndicator() {
    if (!this.enableInput.checked) {
      this.nextInviteIndicator.innerHTML = "Les invitations périodiques sont désactivées"
      return
    }

    if (this.numberOfDaysInput.value) {
      this.nextInviteIndicator.innerHTML = `Une invitation sera envoyée ${this.numberOfDaysInput.value} jour(s) suivant la dernière invitation.`
    } else if (this.dayOfTheMonthInput.value) {
      this.nextInviteIndicator.innerHTML = `Une invitation sera envoyée le ${this.dayOfTheMonthInput.value} de chaque mois.`
    } else if (this.enableInput.checked) {
      this.nextInviteIndicator.innerHTML = "Vous devez configurer la récurrence afin d'activer les invitations périodiques"
    }
  }
}

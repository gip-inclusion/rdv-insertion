import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.selectChanged()
  }

  selectChanged() {
    const selectedElement = this.element.options[this.element.selectedIndex]
    const daysBeforeInviteInput = document.querySelector("#number_of_days_before_next_invite-input-container")

    if (selectedElement?.dataset?.participation_optional === "true") {
      daysBeforeInviteInput.classList.remove("d-none")
    } else {
      daysBeforeInviteInput.classList.add("d-none")
    }
  }
}
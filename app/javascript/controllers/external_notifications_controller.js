import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["noAvailableSlotsInput", "noAvailableSlotsCheck", "rdvChangesCheck", "rdvChangesInput"]

  noAvailableSlotsInputChanged() {
    if (this.noAvailableSlotsInputTarget.value) {
      this.noAvailableSlotsCheckTarget.checked = true;
    } else {
      this.noAvailableSlotsCheckTarget.checked = false;
    }
  }

  rdvChangesInputChanged() {
    if (this.rdvChangesInputTarget.value) {
      this.rdvChangesCheckTarget.checked = true;
    } else {
      this.rdvChangesCheckTarget.checked = false;
    }
  }

  noAvailableSlotsCheckTargetChanged() {
    if (!this.noAvailableSlotsCheckTarget.checked) {
      this.noAvailableSlotsInputTarget.value = "";
    } else {
      this.noAvailableSlotsCheckTarget.checked = false;
      this.noAvailableSlotsInputTarget.focus();
    }
  }

  rdvChangesCheckTargetChanged() {
    if (!this.rdvChangesCheckTarget.checked) {
      this.rdvChangesInputTarget.value = "";
    } else {
      this.rdvChangesCheckTarget.checked = false;
      this.rdvChangesInputTarget.focus();
    }
  }
}

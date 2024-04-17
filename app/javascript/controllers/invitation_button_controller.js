import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  setAsPending() {
    this.element.innerText = "Invitation...";
    // 10ms timeout to delay the disabling of the button for the form to submit before
    setTimeout(() => {
      this.element.disabled = true;
    }, 10);
  }
}

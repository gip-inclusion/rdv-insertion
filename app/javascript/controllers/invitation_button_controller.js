import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  setAsPending() {
    this.element.innerText = "Invitation...";
    this.element.disabled = true;
  }

}

import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["show", "edit"]

  edit() {
    this.showTarget.classList.add("d-none");
    this.editTarget.classList.remove("d-none");
  }

  show() {
    this.showTarget.classList.remove("d-none");
    this.editTarget.classList.add("d-none");
  }
}

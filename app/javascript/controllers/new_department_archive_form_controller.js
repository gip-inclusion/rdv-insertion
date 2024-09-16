import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  submitStart(event) {
    const checkedCheckboxes = this.element.querySelectorAll('input[type="checkbox"]:checked');

    if (checkedCheckboxes.length === 0) {
      event.preventDefault();

      this.element.querySelectorAll('input[type="checkbox"]').forEach((checkbox) => {
        checkbox.classList.add("checkbox-error");
      });
      this.element.querySelector('#error-message').classList.remove("d-none");
    }
  }
}

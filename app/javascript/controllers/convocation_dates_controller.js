import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  toggleHistory() {
    this.motifCategoryId = this.element.dataset.motifCategoryId;

    this.buttons = this.element.querySelectorAll("button");
    this.convocationDatesRow = document.querySelectorAll(`.motif-category-${this.motifCategoryId}-other-convocations`);

    this.convocationDatesRow.forEach((row) => {
      row.classList.toggle("d-none");
    });
    this.buttons.forEach((button) => {
      button.classList.toggle("d-none");
    });
  }
}

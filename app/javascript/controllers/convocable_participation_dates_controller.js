import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  toggleHistory() {
    this.motifCategoryId = this.element.dataset.motifCategoryId;

    this.buttons = this.element.querySelectorAll("button");
    this.convocableParticipationDatesRow = document.querySelectorAll(`.motif-category-${this.motifCategoryId}-other-convocable_participations`);

    this.convocableParticipationDatesRow.forEach((row) => {
      row.classList.toggle("d-none");
    });
    this.buttons.forEach((button) => {
      button.classList.toggle("d-none");
    });
  }
}

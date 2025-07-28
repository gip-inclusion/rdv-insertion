import Flatpickr from "stimulus-flatpickr";
import { French } from "flatpickr/dist/l10n/fr";

require("flatpickr/dist/flatpickr.css");
require("flatpickr/dist/themes/material_red.css");

export default class extends Flatpickr {
  initialize() {
    this.config = {
      locale: French,
    };
  }

  /* eslint-disable no-underscore-dangle */
  updateAfterDateMin() {
    const selectedDate = this.element._flatpickr?.selectedDates[0];
    if (!selectedDate) return;

    // Find the "after" date field in the same container (if many) or in the document and update its min date
    const container = this.element.closest("[data-controller*='flatpickr']")?.parentElement;

    const afterDateElement = container?.querySelector("[data-flatpickr-role='after']") || document.querySelector("[data-flatpickr-role='after']");

    if (afterDateElement && afterDateElement._flatpickr && afterDateElement !== this.element) {
      afterDateElement._flatpickr.set("minDate", selectedDate);
    }
  }

  updateBeforeDateMax() {
    const selectedDate = this.element._flatpickr?.selectedDates[0];
    if (!selectedDate) return;

    // Find the "before" date field in the same container (if many) or in the document and update its max date
    const container = this.element.closest("[data-controller*='flatpickr']")?.parentElement;
    const beforeDateElement = container?.querySelector("[data-flatpickr-role='before']") || document.querySelector("[data-flatpickr-role='before']");

    if (beforeDateElement && beforeDateElement._flatpickr && beforeDateElement !== this.element) {
      beforeDateElement._flatpickr.set("maxDate", selectedDate);
    }
  }
  /* eslint-enable no-underscore-dangle */
}

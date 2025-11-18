import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["button", "hiddenInput", "label", "option", "dropdown"]

  connect() {
    if (this.hiddenInputTarget.value) {
      const selectedOption = this.optionTargets.find(
        option => option.dataset.value === this.hiddenInputTarget.value
      );

      if (selectedOption) {
        this.labelTarget.textContent = selectedOption.dataset.label;
      }
    }
  }

  select(event) {
    const option = event.currentTarget;
    const value = option.dataset.value;
    const label = option.dataset.label;

    this.hiddenInputTarget.value = value;
    this.labelTarget.textContent = label;

    this.#scrollToTop();

    this.element.dispatchEvent(new CustomEvent("select-dropdown:selected", {
      bubbles: true
    }));
  }

  #scrollToTop() {
    if (this.hasDropdownTarget) {
      this.dropdownTarget.scrollTop = 0;
    }
  }
}

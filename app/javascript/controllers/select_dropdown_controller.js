import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["button", "hiddenInput", "label", "option"]

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

    this.#resetFilter();
    this.#closeDropdown();
  }

  #resetFilter() {
    const filterController = this.application.getControllerForElementAndIdentifier(
      this.element,
      "list-filter"
    );

    if (filterController) {
      filterController.reset();
    }
  }

  #closeDropdown() {
    const dropdownController = this.application.getControllerForElementAndIdentifier(
      this.element,
      "dropdown-menu"
    );

    if (dropdownController && dropdownController.isOpen()) {
      dropdownController.toggle();
    }
  }
}

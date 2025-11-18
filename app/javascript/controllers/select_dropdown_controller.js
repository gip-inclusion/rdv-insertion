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

    this.currentIndex = -1;
    this.element.addEventListener("keydown", this.#handleKeydown.bind(this));
  }

  select(event) {
    const option = event.currentTarget;
    const value = option.dataset.value;
    const label = option.dataset.label;

    this.hiddenInputTarget.value = value;
    this.labelTarget.textContent = label;

    this.#scrollToTop();
    this.currentIndex = -1;

    this.element.dispatchEvent(new CustomEvent("select-dropdown:selected", {
      bubbles: true
    }));
  }

  #scrollToTop() {
    if (this.hasDropdownTarget) {
      this.dropdownTarget.scrollTop = 0;
    }
  }

  #handleKeydown(event) {
    const visibleOptions = this.#getVisibleOptions();
    if (visibleOptions.length === 0) return;

    switch(event.key) {
      case "ArrowDown":
        event.preventDefault();
        this.currentIndex += 1;
        if (this.currentIndex >= visibleOptions.length) {
          this.currentIndex = 0;
        }
        this.#updateFocus(visibleOptions);
        break;
      case "ArrowUp":
        event.preventDefault();
        this.currentIndex -= 1;
        if (this.currentIndex < 0) {
          this.currentIndex = visibleOptions.length - 1;
        }
        this.#updateFocus(visibleOptions);
        break;
      case "Enter":
        event.preventDefault();
        if (this.currentIndex >= 0) {
          this.select({ currentTarget: visibleOptions[this.currentIndex] });
        }
        break;
      case "Escape":
        event.preventDefault();
        this.element.dispatchEvent(new CustomEvent("select-dropdown:close", { bubbles: true }));
        break;
      default:
        break;
    }
  }

  #getVisibleOptions() {
    return this.optionTargets.filter(option => !option.classList.contains("d-none"));
  }

  #updateFocus(visibleOptions) {
    visibleOptions.forEach(option => option.classList.remove("keyboard-focused"));
    if (this.currentIndex >= 0) {
      const focusedOption = visibleOptions[this.currentIndex];
      focusedOption.classList.add("keyboard-focused");
      focusedOption.scrollIntoView({ block: "nearest" });
    }
  }
}

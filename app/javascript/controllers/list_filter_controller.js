import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "item", "noResults"]

  connect() {
    // search is optional in case of low number of items so input target is optional
    if (this.hasInputTarget) {
      document.addEventListener("click", (event) => {
        // Reset filter state (empty input and unfiltered items) when clicking outside the dropdown
        if (!this.element.contains(event.target) && this.hasInputTarget) {
          this.inputTarget.value = "";
          this.#unhideAllItems();
        }
      });
    }
  }

  search() {
    const searchText = this.inputTarget.value.toLowerCase().trim();

    if (searchText === "") {
      this.#unhideAllItems();
      return;
    }

    let foundItemsCount = 0;
    this.itemTargets.forEach(item => {
      const itemText = item.textContent.toLowerCase();
      if (itemText.includes(searchText)) {
        item.classList.remove("d-none");
        foundItemsCount += 1;
      } else {
        item.classList.add("d-none");
      }
    });

    if (foundItemsCount === 0) {
      this.noResultsTarget.classList.remove("d-none");
    } else {
      this.noResultsTarget.classList.add("d-none");
    }
  }

  #unhideAllItems() {
    this.itemTargets.forEach(item => {
      item.classList.remove("d-none");
    });

    this.noResultsTarget.classList.add("d-none");
  }
}

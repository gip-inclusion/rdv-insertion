import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "item", "noResults"]

  connect() {
    // filter is optional in case of low number of organisations so input target is optional
    if (this.hasInputTarget) {
      document.addEventListener("click", (event) => {
        // reset input value and show all items when clicking outside the dropdown
        if (!this.element.contains(event.target) && this.hasInputTarget) {
          this.inputTarget.value = "";
          this.#showAllItems();
        }
      });
    }
  }

  filter() {
    if (!this.hasInputTarget) return;

    const searchText = this.inputTarget.value.toLowerCase().trim();

    if (searchText === "") {
      this.#showAllItems();
      return;
    }

    let visibleCount = 0;
    this.itemTargets.forEach(item => {
      const itemText = item.textContent.toLowerCase();
      if (itemText.includes(searchText)) {
        item.classList.remove("d-none");
        visibleCount += 1;
      } else {
        item.classList.add("d-none");
      }
    });

    this.noResultsTarget.style.display = visibleCount === 0 ? "block" : "none";
  }

  #showAllItems() {
    this.itemTargets.forEach(item => {
      item.classList.remove("d-none");
    });

    this.noResultsTarget.style.display = "none";
  }
}

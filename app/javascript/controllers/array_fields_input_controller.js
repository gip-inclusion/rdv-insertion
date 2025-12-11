import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.hideRemoveButtonIfNecessary();
  }

  remove() {
    this.element.parentElement.remove();
    this.hideRemoveButtonIfNecessary();
  }

  add(event) {
    event.preventDefault();
    // if there was only one row, we reactivate the remove button
    this.element.previousElementSibling
      .querySelector(".text-array__remove")
      .classList.remove("d-none");
    const newRow = this.element.previousElementSibling
      .querySelector(".text-array__row")
      .cloneNode(true);

    newRow.querySelector(".array-input").placeholder = "";
    newRow.querySelector(".array-input").value = "";
    this.element.previousElementSibling.appendChild(newRow);
  }

  // We need to hide the remove button when there's only one row, otherwise there would be nothing to clone
  hideRemoveButtonIfNecessary() {
    document.querySelectorAll(".text-array").forEach((el) => {
      const rows = el.querySelectorAll(".text-array__row");
      if (rows.length === 1) {
        rows[0].querySelector(".text-array__remove").classList.add("d-none");
      }
    });
  }
}

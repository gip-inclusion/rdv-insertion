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
    this.element.previousElementSibling.childNodes[3].removeAttribute("style");
    // we duplicate the last array input field
    const newRow = this.element.previousElementSibling.cloneNode(true);
    // we clear the field value
    newRow.childNodes[1].value = "";
    this.element.before(newRow);
  }

  // We need to hide the remove button when there's only one row, otherwise there would be nothing to clone
  hideRemoveButtonIfNecessary() {
    document.querySelectorAll(".text-array").forEach((el) => {
      const rows = el.querySelectorAll(".text-array__row");
      if (rows.length === 1) {
        rows[0].querySelector(".text-array__remove").style.display = "none";
      }
    });
  }
}

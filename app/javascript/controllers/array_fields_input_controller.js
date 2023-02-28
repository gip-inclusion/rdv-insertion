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
    // if this is the only row, we display the reactivate the remove button
    this.element.previousElementSibling.childNodes[3].removeAttribute("style");
    // we duplicate the last array input field
    const newRow = this.element.previousElementSibling.cloneNode(true);
    // we clear the field value
    newRow.childNodes[1].value = "";
    this.element.before(newRow);
  }

  // We need to hide button so they can't remove the only row, otherwise there would be nothing to clone.
  hideRemoveButtonIfNecessary() {
    document.querySelectorAll(".text-array").forEach((el) => {
      const rows = el.querySelectorAll(".text-array__row");
      if (rows.length === 1) {
        rows[0].querySelector(".text-array__remove").style.display = "none";
      }
    });
  }
}

import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["rowToExpand"];

  toggle(event) {
    const RowId = event.params.id

    const rowToExpand = this.rowToExpandTargets.find(
      target => target.dataset.expandableRowsId === RowId
    )

    const icon = event.currentTarget.querySelector("i")

    rowToExpand.classList.toggle("d-none")
    icon.classList.toggle("ri-arrow-down-s-line")
    icon.classList.toggle("ri-arrow-up-s-line")
  }
}

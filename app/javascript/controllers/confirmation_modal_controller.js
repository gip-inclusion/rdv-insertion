import { Controller } from "@hotwired/stimulus";
import { Modal } from "bootstrap";

export default class extends Controller {
  static targets = ["modal"]

  connect() {
    this.linkElement = this.element

    // Prevent the default action of the link
    this.linkElement.addEventListener("click", (event) => {
      event.preventDefault();
      event.stopPropagation();
    });
  }

  show() {
    if (this.modalTarget) {
      // we clone the modal and append it to the body to not apply the parent css classes
      const modalClone = this.modalTarget.content.querySelector(".modal").cloneNode(true);

      // we add the confirm-link and turbo-method to the confirm button of the cloned modal
      // that will be used in the ConfirmButtonController
      const confirmButton = modalClone.querySelector("button[data-controller='confirm-button']");
      confirmButton.dataset.linkUrl = this.linkElement.href;
      confirmButton.dataset.turboMethod = this.element.dataset.turboMethod;

      document.body.appendChild(modalClone);
      this.modal = new Modal(modalClone);
      this.modal.show();
    }
  }
}

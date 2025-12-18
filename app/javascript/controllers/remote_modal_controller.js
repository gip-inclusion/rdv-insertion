import { Controller } from "@hotwired/stimulus";
import { Modal } from "bootstrap";

export default class extends Controller {
  connect() {
    this.modal = new Modal(this.element);
    this.modal.show();

    // Listener for when the modal is closed
    this.element.addEventListener("hidden.bs.modal", () => {
      if (this.#shouldReloadOnClose()) {
        window.location.reload();
      }
    });
  }

  disconnect() {
    // Clean up backdrop if modal was removed while open (multiple modals scenario)
    document.querySelectorAll(".modal-backdrop").forEach(el => el.remove());
    document.body.classList.remove("modal-open");
    document.body.style.removeProperty("overflow");
    document.body.style.removeProperty("padding-right");
  }

  hideBeforeRender(event) {
    if (this.isOpen()) {
      event.preventDefault();
      this.element.addEventListener("hidden.bs.modal", event.detail.resume);
      this.modal.hide();
    }
  }

  isOpen() {
    return this.element.classList.contains("show");
  }

  submitEnd(e) {
    if (!e.detail.success && this.#displayErrorsInsideModal()) return;

    this.modal.hide();
  }

  #displayErrorsInsideModal() {
    return !!this.element.querySelector("#error_list");
  }


  #shouldReloadOnClose() {
    return this.element.dataset.reloadOnClose === "true";
  }
}

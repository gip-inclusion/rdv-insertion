import { Modal } from "bootstrap";

class ConfirmModal {
  constructor() {
    this.modalPartial = document.querySelector("#confirm-modal");
    window.Turbo.setConfirmMethod(this.confirm.bind(this));
    this.checkForExternalConfirmLinks();
  }

  checkForExternalConfirmLinks() {
    // Turbo automatically handles confirmation of internal links (those handled by Rails)
    // but by default there's no way to handle confirmation of external links.
    // This code automatically detects external links with a data-turbo-confirm attribute
    // and shows the confirmation modal when they are clicked.
    document.querySelectorAll("[data-turbo-confirm]").forEach((element) => {
      if (element.target !== "_blank") return;
      
      element.addEventListener("click", (event) => {
        event.preventDefault();
        this.confirm(element.getAttribute("data-turbo-confirm")).then(() => {
          this.modal.hide();
        });
      });
    });
  }

  confirm(template) {
    const modalContent = document.getElementById(template).cloneNode(true);

    this.modal = new Modal(modalContent);
    this.modal.show();

    return new Promise((resolve) => {
      modalContent.querySelector("#confirm-button").addEventListener("click", () => {
        resolve(true);
      });
    });
  }
}

export default ConfirmModal;

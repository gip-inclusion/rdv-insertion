import { Controller } from "@hotwired/stimulus"
import Rails from "@rails/ujs"

export default class extends Controller {
  confirm() {
    const { turboMethod, linkUrl } = this.element.dataset;

    if (turboMethod === "delete") {
      this.#createFormAndSubmitForDelete(linkUrl);
    } else {
      window.location.href = linkUrl;
    }
  }

  #createFormAndSubmitForDelete(confirmLink) {
    const form = document.createElement("form");
    form.method = "post";
    form.action = confirmLink;

    const methodInput = document.createElement("input");
    methodInput.type = "hidden";
    methodInput.name = "_method";
    methodInput.value = "DELETE";
    form.appendChild(methodInput);

    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content;

    if (csrfToken) {
      const csrfInput = document.createElement("input");
      csrfInput.type = "hidden";
      csrfInput.name = "authenticity_token";
      csrfInput.value = csrfToken;
      form.appendChild(csrfInput);
    }

    document.body.appendChild(form);
    // needed to use Rails submit a form that handles turbo stream response
    Rails.fire(form, "submit");
  }
}

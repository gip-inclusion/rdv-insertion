import { Controller } from "@hotwired/stimulus"
import Rails from "@rails/ujs"

export default class extends Controller {
  confirm() {
    const { turboMethod, linkUrl, turboPayload } = this.element.dataset;

    if (turboMethod) {
      this.#createFormAndSubmit(linkUrl, turboMethod, JSON.parse(turboPayload || "{}"));
    } else {
      window.location.href = linkUrl;
    }
  }

  #createFormAndSubmit(url, method, payload = {}) {
    const form = document.createElement("form");
    form.method = "post";
    form.action = url;

    const methodInput = document.createElement("input");
    methodInput.type = "hidden";
    methodInput.name = "_method";
    methodInput.value = method.toUpperCase();
    form.appendChild(methodInput);


    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content;
    if (csrfToken) {
      const csrfInput = document.createElement("input");
      csrfInput.type = "hidden";
      csrfInput.name = "authenticity_token";
      csrfInput.value = csrfToken;
      form.appendChild(csrfInput);
    }

    this.#appendPayloadToForm(form, payload);

    document.body.appendChild(form);
    // needed to use Rails submit a form that handles turbo stream response
    Rails.fire(form, "submit");
  }

  #appendPayloadToForm(form, payload, prefix = "") {
    Object.entries(payload).forEach(([key, value]) => {
      const fieldName = prefix ? `${prefix}[${key}]` : key;
      if (typeof value === "object" && value !== null) {
        this.#appendPayloadToForm(form, value, fieldName);
      } else {
        const input = document.createElement("input");
        input.type = "hidden";
        input.name = fieldName;
        input.value = value;
        form.appendChild(input);
      }
    });
  }
}

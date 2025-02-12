import { Controller } from "@hotwired/stimulus";
import createInvitationLetter from "../react/lib/createInvitationLetter";

export default class extends Controller {
  connect() {
    this.button = this.element.querySelector("button");
    this.initialButtonHTML = this.button.innerHTML;
    this.initialButtonText = this.button.innerText;
  }

  submit() {
    this.element.addEventListener("turbo:submit-end", this.handleSubmitEnd.bind(this));
    this.displayButtonAsLoading();
    window.Turbo.navigator.submitForm(this.element);
  }

  async generatePostalInvitation() {
    this.displayButtonAsLoading();

    const result = await createInvitationLetter(
      this.element.dataset.userId,
      this.element.dataset.departmentId,
      this.element.dataset.organisationId,
      this.element.dataset.isDepartmentLevel,
      this.element.dataset.motifCategoryId
    );

    this.button.innerHTML = this.initialButtonHTML
    if (result.success && this.initialButtonText === "Inviter") {
      this.button.innerText = "Révinviter";
    }
    this.button.disabled = false;
  }

  disconnect() {
    this.element.removeEventListener("turbo:submit-end", this.handleSubmitEnd.bind(this));
  }

  displayButtonAsLoading() {
    this.button.innerHTML = "Invitation...";
    this.button.disabled = true;
  }

  handleSubmitEnd(event) {
    const response = event.detail
    // If the response is successful, the necessary changes are made in the DOM
    if (response.success === false) {
      this.button.innerText = this.initialButtonText;
      this.button.disabled = false;
    }
  }
}

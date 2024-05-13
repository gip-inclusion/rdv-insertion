import { Controller } from "@hotwired/stimulus";
import createInvitationLetter from "../react/lib/createInvitationLetter";

export default class extends Controller {
  connect() {
    this.button = this.element.querySelector("button");
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
    if (result.errors) {
      // The errors are displayed by rails
      this.button.innerText = this.initialButtonText;
    } else {
      this.button.innerText = "Révinviter";
    }
    this.button.disabled = false;
    return true;
  }

  disconnect() {
    this.element.removeEventListener("turbo:submit-end", this.handleSubmitEnd.bind(this))
  }

  displayButtonAsLoading() {
    this.button.innerText = "Invitation...";
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

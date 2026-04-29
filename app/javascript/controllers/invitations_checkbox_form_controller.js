import { Controller } from "@hotwired/stimulus";
import DOMPurify from "dompurify";
import safeTippy from "../lib/safeTippy";
import handleUserInvitation from "../lib/handleUserInvitation";
import { getFrenchFormatDateString, todaysDateString } from "../lib/datesHelper";

export default class extends Controller {
  connect() {
    this.button = this.element.querySelector("button[type=submit]");
    if (!this.button) return;

    this.icon = this.button.querySelector("i");
    this.refreshTooltip();
  }

  disconnect() {
    this.tippyInstance?.destroy();
  }

  submit(event) {
    if (this.disabled()) {
      event.preventDefault();
      return;
    }
    this.showSpinner();
  }

  async submitStart(event) {
    // We have to use JSON instead of Turbostream because postal invitation return raw data as pdfs
    const body = Object.fromEntries(event.detail.formSubmission.fetchRequest.entries);
    event.detail.formSubmission.stop();

    const result = await this.sendInvitation(body);
    this.hideSpinner();

    if (result.success) this.handleSuccess();
  }

  sendInvitation(body) {
    const { userId, departmentId, organisationId } = this.element.dataset;
    return handleUserInvitation(
      userId, departmentId, organisationId, !organisationId,
      body.motif_category_id, body.invitation_format
    );
  }

  handleSuccess() {
    this.switchToInvitedState();

    const { followUpId } = this.element.dataset;
    this.updateFirstInvitationDate(followUpId);
    this.updateLastInvitationDate(followUpId);
    this.updateStatus(followUpId);
  }

  switchToInvitedState() {
    this.icon.classList.remove("ri-checkbox-blank-line");
    this.icon.classList.add("ri-refresh-line");
    this.button.classList.add("invitation-refresh-disabled");
    this.refreshTooltip();
  }

  showSpinner() {
    this.button.hidden = true;
    this.button.parentElement.classList.add("spinner-border", "spinner-border-sm");
  }

  hideSpinner() {
    this.button.hidden = false;
    this.button.parentElement.classList.remove("spinner-border", "spinner-border-sm");
  }

  refreshTooltip() {
    this.tippyInstance?.destroy();
    this.tippyInstance = safeTippy(this.button, { content: this.tooltipContent() });
  }

  tooltipContent() {
    const { invitationFormat } = this.element.dataset;
    if (invitationFormat === "postal") return "Générer courrier d'invitation";
    if (this.disabled()) return `Une invitation ${invitationFormat} a déjà été envoyée aujourd'hui à cet usager`;
    if (this.alreadyInvited()) return `Renvoyer ${invitationFormat} d'invitation`;
    return `Envoyer ${invitationFormat} d'invitation`;
  }

  alreadyInvited() {
    return this.icon.classList.contains("ri-refresh-line");
  }

  disabled() {
    return this.button.classList.contains("invitation-refresh-disabled");
  }

  updateFirstInvitationDate(followUpId) {
    const firstInvitationDate = document.getElementById(`first-invitation-date-${followUpId}`);
    if (firstInvitationDate.innerHTML === " - ") {
      firstInvitationDate.innerHTML = DOMPurify.sanitize(getFrenchFormatDateString(todaysDateString()));
    }
  }

  updateLastInvitationDate(followUpId) {
    const lastInvitationDate = document.getElementById(`last-invitation-date-${followUpId}`);
    lastInvitationDate.innerHTML = DOMPurify.sanitize(getFrenchFormatDateString(todaysDateString()));
  }

  updateStatus(followUpId) {
    const status = document.getElementById(`follow-up-status-${followUpId}`);
    status.classList = [];
    status.innerHTML = DOMPurify.sanitize("Invitation en attente de réponse");
  }
}

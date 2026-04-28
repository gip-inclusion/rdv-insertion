import { Controller } from "@hotwired/stimulus";
import { navigator } from "@hotwired/turbo";
import DOMPurify from "dompurify";
import safeTippy from "../lib/safeTippy";
import handleUserInvitation from "../lib/handleUserInvitation";
import { getFrenchFormatDateString, todaysDateString } from "../lib/datesHelper";

export default class extends Controller {
  connect() {
    const checkbox = this.element.querySelector("input[type=checkbox]");
    if (!checkbox) return null;

    const refreshLabel = checkbox.labels[0];
    const { invitationFormat } = this.element.dataset;
    return safeTippy(refreshLabel || checkbox, { content: this.tooltipContent(invitationFormat, !!refreshLabel) });
  }

  tooltipContent(invitationFormat, alreadyInvited) {
    if (invitationFormat === "postal") return "Générer courrier d'invitation";
    if (alreadyInvited) return `Renvoyer ${invitationFormat} d'invitation`;
    return `Envoyer ${invitationFormat} d'invitation`;
  }

  submit() {
    this.element.hidden = true;
    if (this.element.labels[0]) {
      this.element.labels[0].hidden = true;
    }
    this.element.parentElement.classList.add("spinner-border", "spinner-border-sm");
    navigator.submitForm(this.element.closest("form"));
  }

  async submitStart(event) {
    // We have to use JSON instead of Turbostream because postal invitation return raw data as pdfs
    const body = Object.fromEntries(event.detail.formSubmission.fetchRequest.entries);
    event.detail.formSubmission.stop();
    const { userId, departmentId, organisationId, followUpId } = this.element.dataset;

    const isDepartmentLevel = !organisationId;
    const result = await handleUserInvitation(
      userId,
      departmentId,
      organisationId,
      isDepartmentLevel,
      body.motif_category_id,
      body.invitation_format
    );

    const checkbox = this.element.querySelector("input[type=checkbox]");

    checkbox.hidden = false;
    checkbox.parentElement.classList.remove("spinner-border", "spinner-border-sm");
    if (result.success) {
      checkbox.disabled = true;
      checkbox.classList = "";
      this.updateFirstInvitationDate(followUpId);
      this.updateLastInvitationDate(followUpId);
      this.updateStatus(followUpId);
    } else {
      checkbox.checked = false;
      if (checkbox.labels[0]) {
        checkbox.labels[0].hidden = false;
      }
    }
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

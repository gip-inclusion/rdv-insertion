import { Controller } from "@hotwired/stimulus";
import { navigator } from "@hotwired/turbo";
import tippy from "tippy.js";
import handleApplicantInvitation from "../react/lib/handleApplicantInvitation";
import { getFrenchFormatDateString, todaysDateString } from "../lib/datesHelper";

export default class extends Controller {
  connect() {
    const checkbox = this.element.querySelector("input[type=checkbox]");
    const { invitationFormat } = this.element.dataset;
    if (!checkbox) return null;

    if (invitationFormat === "postal") {
      return tippy(checkbox, {
        content: "Générer courrier d'invitation",
      });
    }

    return tippy(checkbox, {
      content: `Envoyer ${invitationFormat} d'invitation`,
    });
  }

  submit() {
    this.element.hidden = true;
    this.element.parentElement.classList.add("spinner-border", "spinner-border-sm");
    navigator.submitForm(this.element.closest("form"));
  }

  async submitStart(event) {
    // We have to use JSON instead of Turbostream because postal invitation return raw data as pdfs
    const body = Object.fromEntries(event.detail.formSubmission.fetchRequest.entries);
    event.detail.formSubmission.stop();
    const { applicantId, departmentId, organisationId } = this.element.dataset;
    const rdvContext = JSON.parse(this.element.dataset.rdvContext);

    const isDepartmentLevel = !organisationId;

    const result = await handleApplicantInvitation(
      applicantId,
      departmentId,
      organisationId,
      isDepartmentLevel,
      body.motif_category,
      body.help_phone_number,
      body.invitation_format
    );

    const checkbox = this.element.querySelector("input[type=checkbox]");

    checkbox.hidden = false;
    checkbox.parentElement.classList.remove("spinner-border", "spinner-border-sm");
    if (result.success) {
      checkbox.disabled = true;
      this.updateFirstInvitationDate(rdvContext);
      this.updateLastInvitationDate(rdvContext);
      this.updateStatus(rdvContext);
    } else {
      checkbox.checked = false;
    }
  }

  updateFirstInvitationDate(rdvContext) {
    const firstInvitationDate = document.getElementById(`first-invitation-date-${rdvContext.id}`);
    if (firstInvitationDate.innerHTML === " - ") {
      firstInvitationDate.innerHTML = getFrenchFormatDateString(todaysDateString());
    }
  }

  updateLastInvitationDate(rdvContext) {
    const lastInvitationDate = document.getElementById(`last-invitation-date-${rdvContext.id}`);
    lastInvitationDate.innerHTML = getFrenchFormatDateString(todaysDateString());
  }

  updateStatus(rdvContext) {
    const status = document.getElementById(`rdv-context-status-${rdvContext.id}`);
    status.classList = [];
    status.innerHTML = "Invitation en attente de réponse";
  }
}

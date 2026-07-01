import { Controller } from "@hotwired/stimulus";
import createInvitationLetter from "../lib/createInvitationLetter";

export default class extends Controller {
  async submit(event) {
    event.preventDefault();

    const { userId, departmentId, organisationId, motifCategoryId, origin } = this.element.dataset;

    await createInvitationLetter(
      userId, departmentId, organisationId, !organisationId, motifCategoryId, origin
    );
  }
}

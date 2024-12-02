import Swal from "sweetalert2";
import { Controller } from "@hotwired/stimulus";
import retrieveRelevantOrganisation from "../lib/retrieveRelevantOrganisation";
import appFetch from "../lib/appFetch";

export default class extends Controller {
  async selectOrganisationAndSaveUser(event) {
    event.preventDefault();
    this.setAssigningOrgText()

    const { departmentNumber, userAddress } = this.element.dataset;

    // TODO: remove ability to pass "organisationSearchTerms" to retrieveRelevantOrganisation after fully migrated to new upload
    const organisation = await retrieveRelevantOrganisation(departmentNumber, null, userAddress);

    if (organisation === null) {
      this.resetButtonText();
      return;
    }

    const response = await this.updateRow(organisation.id);
    if (response.success) {
      this.setSavingUserText()
      const saveAttemptResponse = await this.saveRowUser();
      if (saveAttemptResponse.success) {
        Swal.fire({
          icon: "success",
          title: "Organisation assignée avec succès",
          showConfirmButton: false,
          timer: 3000
        });
        event.stopPropagation();
      } else {
        Swal.fire("Impossible de sauvegarder l'usager", saveAttemptResponse.errors[0], "error");
        this.resetButtonText();
      }
    } else {
      Swal.fire("Impossible d'assigner l'organisation", response.errors[0], "error");
      this.resetButtonText();
    }

  }

  setAssigningOrgText() {
    this.element.textContent = "Organisation en cours d'assignation...";
  }

  setSavingUserText() {
    this.element.textContent = "Sauvegarde de l'usager en cours..."
  }

  resetButtonText() {
    this.element.textContent = "Assigner l'organisation";
  }

  async updateRow(organisationId) {
    const response = await appFetch(`/user_list_uploads/${this.element.dataset.userListUploadId}/user_rows/${this.element.dataset.uid}`,
      "PATCH",
      { assigned_organisation_id: organisationId },
    );
    return response;
  }

  async saveRowUser() {
    const response = await appFetch(`/user_list_uploads/${this.element.dataset.userListUploadId}/user_save_attempts`,
      "POST",
      { row_uid: this.element.dataset.uid },
    );
    return response;
  }
}


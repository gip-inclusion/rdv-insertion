import { Controller } from "@hotwired/stimulus";
import retrieveRelevantOrganisation from "../lib/retrieveRelevantOrganisation";

export default class extends Controller {
  async submit(event) {
    event.preventDefault();
    const organisation = await retrieveRelevantOrganisation(
      this.element.dataset.departmentNumber,
      this.element.querySelector("#user_address").value,
    )

    if (organisation?.id) {
      this.element.querySelector("#user_organisation_ids").value = organisation.id;
      this.element.submit();
    }
  }
}
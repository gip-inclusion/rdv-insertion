import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["organisationsList", "agentsList"];

  connect() {
    this.agentIdsByOrganisationId = JSON.parse(this.element.dataset.agentIdsByOrganisationId);
    this.setAgentsList();
  }

  setAgentsList() {
    this.unhideAgentsOptions();
    this.selectedOrganisationId = this.organisationsListTarget.selectedOptions[0].value;

    if (this.selectedOrganisationId) {
      Array.from(this.agentsListTarget.options).forEach((option, index) => {
        if (
          option.value &&
          !this.agentIdsByOrganisationId[this.selectedOrganisationId].includes(
            parseInt(option.value, 10)
          )
        ) {
          this.agentsListTarget.options[index].classList.add("d-none");
          this.agentsListTarget.options[index].selected = false;
        }
      });
      this.agentsListTarget.disabled = false;
    } else {
      this.agentsListTarget.disabled = true;
    }
  }

  unhideAgentsOptions() {
    Array.from(this.agentsListTarget.options).forEach((option, index) => {
      this.agentsListTarget.options[index].classList.remove("d-none");
    });
  }
}

class OrganisationSelector {
  constructor() {
    this.selectElt = document.querySelector(".js-organisation-selector");
    if (this.selectElt === null) return;

    this.attachListener();
  }

  attachListener() {
    this.selectElt.addEventListener("change", (event) => {
      this.refreshQuery(event.target.value);
    });
  }



  refreshQuery(selectedOrganisation) {
    let url;
    if (selectedOrganisation && selectedOrganisation !== "0") {
      url = new URL(`${window.location.origin}/organisations/${selectedOrganisation}/stats`);
    } else {
      const currentDepartmentId = document.getElementById("department_id").value
      url = new URL(`${window.location.origin}/departments/${currentDepartmentId}/stats`);
    }
    window.location.href = url;
  }
}

export default OrganisationSelector;

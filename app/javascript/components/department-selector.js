class DepartmentSelector {
  constructor() {
    this.selectElt = document.querySelector(".js-department-selector");
    if (this.selectElt === null) return;

    this.attachListener();
  }

  attachListener() {
    this.selectElt.addEventListener("change", (event) => {
      this.refreshQuery(event.target.value);
    });
  }

  refreshQuery(selectedDepartment) {
    if (selectedDepartment && selectedDepartment !== "0") {
      const url = new URL(`${window.location.origin}/stats/${selectedDepartment}`);
      window.location.href = url;
    } else {
      const url = new URL(`${window.location.origin}/stats`);
      window.location.href = url;
    }
  }
}

export default DepartmentSelector;

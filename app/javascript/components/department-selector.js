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
    let url;
    if (selectedDepartment && selectedDepartment !== "0") {
      url = new URL(`${window.location.origin}/departments/${selectedDepartment}/stats`);
    } else {
      url = new URL(`${window.location.origin}/stats`);
    }

    new URL(window.location.href).searchParams.forEach((value, key) => {
      url.searchParams.append(key, value);
    });
  
    window.location.href = url;
  }
}

export default DepartmentSelector;

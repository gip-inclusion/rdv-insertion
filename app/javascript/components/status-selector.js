class StatusSelector {
  constructor() {
    this.selectElt = document.querySelector(".js-status-selector");
    if (this.selectElt === null) return;

    this.setInitialValue();
    this.attachListener();
  }

  setInitialValue() {
    const url = new URL(window.location.href);
    const selectedStatus = url.searchParams.get("status");
    if (selectedStatus) {
      this.selectElt.value = selectedStatus;
    }
  }

  attachListener() {
    this.selectElt.addEventListener("change", (event) => {
      this.refreshQuery(event.target.value);
    });
  }

  refreshQuery(selectedStatus) {
    const url = new URL(window.location.href);
    if (selectedStatus) {
      url.searchParams.set("status", selectedStatus);
    } else {
      url.searchParams.delete("status");
    }
    window.location.href = url;
  }
}

export default StatusSelector;

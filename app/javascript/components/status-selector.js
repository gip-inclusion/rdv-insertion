class StatusSelector {
  constructor() {
    this.selectElt = document.querySelector(".js-status-selector");
    if (this.selectElt === null) return;

    this.setIntialValue();
    this.attachListener();
  }

  setIntialValue() {
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
    if (selectedStatus) {
      const url = new URL(window.location.href);
      url.searchParams.set("status", selectedStatus);
      window.location.href = url;
    }
  }
}

export default StatusSelector;

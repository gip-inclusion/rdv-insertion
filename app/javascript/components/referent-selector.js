class ReferentSelector {
  constructor() {
    this.selectElt = document.querySelector(".js-referent-selector");
    if (this.selectElt === null) return;

    this.setIntialValue();
    this.attachListener();
  }

  setIntialValue() {
    const url = new URL(window.location.href);
    const selectedReferentId = url.searchParams.get("referent_id");
    if (selectedReferentId) {
      this.selectElt.value = selectedReferentId;
    }
  }

  attachListener() {
    this.selectElt.addEventListener("change", (event) => {
      this.refreshQuery(event.target.value);
    });
  }

  refreshQuery(selectedReferentId) {
    if (selectedReferentId) {
      const url = new URL(window.location.href);
      url.searchParams.set("referent_id", selectedReferentId);
      window.location.href = url;
    }
  }
}

export default ReferentSelector;

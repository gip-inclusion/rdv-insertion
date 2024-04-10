class ReferentSelector {
  constructor() {
    this.selectElt = document.querySelector(".js-referent-selector");
    if (this.selectElt === null) return;

    this.setInitialValue();
    this.attachListener();
  }

  setInitialValue() {
    const url = new URL(window.location.href);
    const selectedReferentId = url.searchParams.get("referent_id");
    if (selectedReferentId) {
      this.selectElt.value = selectedReferentId;
      this.setAlternativeLabel();
    }
  }

  setAlternativeLabel() {
    this.selectElt.options[this.selectElt.selectedIndex].innerText = `Suivis par : ${this.selectElt.options[this.selectElt.selectedIndex].innerText}`
  }

  attachListener() {
    this.selectElt.addEventListener("focus", () => {
      if (this.selectElt.value) {
        this.selectElt.options[this.selectElt.selectedIndex].innerText = this.selectElt.options[this.selectElt.selectedIndex].innerText.replace("Suivi par : ", "")
      }
    })
    this.selectElt.addEventListener("change", (event) => {
      this.refreshQuery(event.target.value);
      this.setAlternativeLabel();
    });
  }

  refreshQuery(selectedReferentId) {
    const url = new URL(window.location.href);
    if (selectedReferentId) {
      url.searchParams.set("referent_id", selectedReferentId);
    } else {
      url.searchParams.delete("referent_id");
    }
    window.location.href = url;
  }
}

export default ReferentSelector;

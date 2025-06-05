class ReferentSelector {
  constructor() {
    this.selectElt = document.querySelector(".js-referent-selector");
    this.altLabel = document.querySelector(".referent-label-alt");
    if (this.selectElt === null) return;

    this.setInitialValue();
    this.attachListener();
  }

  setInitialValue() {
    const url = new URL(window.location.href);
    const selectedReferentId = url.searchParams.get("referent_id");
    if (selectedReferentId) {
      this.selectElt.value = selectedReferentId;
    }
  }

  setAlternativeLabel() {
    if (this.selectElt.value) {
      this.altLabel.innerText = `Suivis par : ${this.selectElt.options[this.selectElt.selectedIndex].text}`;
    } else {
      this.altLabel.innerText = "Filtrer par référent";
    }
  }

  attachListener() {
    this.selectElt.addEventListener("change", (event) => {
      // this.setAlternativeLabel();
      this.refreshQuery(event.target.value);
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
